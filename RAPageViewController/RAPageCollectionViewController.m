//
//  RAPageCollectionViewController.m
//  RAPageViewController
//
//  Created by Evadne Wu on 12/24/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RAPageCollectionView.h"
#import "RAPageCollectionViewCell.h"
#import "RAPageCollectionViewController.h"
#import "RAPageCollectionViewFlowLayout.h"
#import "RAPageCollectionViewSpacer.h"
#import "RADeferredOperation.h"

static NSString * const RAPageCollectionViewDidEndScrollAnimationNotification = @"RAPageCollectionViewDidEndScrollAnimationNotification";

@interface RAPageCollectionViewController () <RAPageCollectionViewCellDelegate, RAPageCollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, readwrite, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, readonly, strong) NSOperationQueue *animationQueue;

@end

@implementation RAPageCollectionViewController
@synthesize collectionView = _collectionView;
@synthesize collectionViewLayout = _collectionViewLayout;
@synthesize lastIndexPath = _lastIndexPath;
@synthesize animationQueue = _animationQueue;

+ (Class) collectionViewCellClass {

	return [RAPageCollectionViewCell class];

}

+ (Class) collectionViewCellReuseIdentifier {

	return @"Cell";

}

- (void) viewDidLoad {
	
	[super viewDidLoad];
	
	[self.view addSubview:self.collectionView];
	[self.collectionView reloadData];
	self.collectionViewLayout.itemSize = self.view.bounds.size;
	
	if ([self.delegate numberOfViewControllersInPageCollectionViewController:self]) {
		
		self.lastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
		
	}
	
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

	return [self.delegate numberOfViewControllersInPageCollectionViewController:self];

}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	NSString * const identifier = [[self class] collectionViewCellReuseIdentifier];
	RAPageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
	
	UIViewController *viewController = [self.delegate viewControllerForPageAtIndex:indexPath.item inPageCollectionViewController:self];
	
	cell.delegate = self;
	cell.parentViewController = self;
	
	cell.childViewController = ([viewController isViewLoaded] && (viewController.view.superview == self.view)) ? nil : viewController;
	
	return cell;

}

- (UICollectionView *) collectionView {

	if (!_collectionView) {
	
		if (![self isViewLoaded])
			return nil;
	
		UICollectionViewFlowLayout *layout = self.collectionViewLayout;
		CGRect frame = CGRectInset(
			self.view.bounds,
			-0.5f * layout.minimumLineSpacing,
			-0.5f * layout.minimumLineSpacing
		);
		
		_collectionView = [[RAPageCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
		_collectionView.dataSource = self;
		_collectionView.delegate = self;
		_collectionView.backgroundColor = [UIColor whiteColor];
		_collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		_collectionView.pagingEnabled = YES;
		_collectionView.clipsToBounds = NO;
		
		//	If you change the scroll direction later, you’re responsible for twiddling the bouncy bits
		
		_collectionView.alwaysBounceHorizontal = (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal);
		_collectionView.alwaysBounceVertical = (layout.scrollDirection == UICollectionViewScrollDirectionVertical);
		
		_collectionView.showsHorizontalScrollIndicator = NO;
		_collectionView.showsVerticalScrollIndicator = NO;
				
		[_collectionView registerClass:[[self class] collectionViewCellClass] forCellWithReuseIdentifier:[[self class] collectionViewCellReuseIdentifier]];
		
		[_collectionView registerClass:[RAPageCollectionViewSpacer class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Spacer"];
		
		[_collectionView registerClass:[RAPageCollectionViewSpacer class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Spacer"];
			
	}
	
	return _collectionView;

}

- (UICollectionViewFlowLayout *) collectionViewLayout {

	if (!_collectionViewLayout) {
	
		_collectionViewLayout = [RAPageCollectionViewFlowLayout new];
		_collectionViewLayout.minimumLineSpacing = 16.0f;
		_collectionViewLayout.minimumInteritemSpacing = 16.0f;
		_collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		_collectionViewLayout.headerReferenceSize = (CGSize){ 8, 8 };
		_collectionViewLayout.footerReferenceSize = (CGSize){ 8, 8 };
				
	}
	
	return _collectionViewLayout;

}

- (void) collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

	if ([cell isKindOfClass:[RAPageCollectionViewCell class]]) {
	
		RAPageCollectionViewCell *pageCollectionViewCell = (RAPageCollectionViewCell *)cell;
		pageCollectionViewCell.childViewController = nil;
		pageCollectionViewCell.parentViewController = nil;
	
	}

}

- (CGFloat) pageSpacing {

	return self.collectionViewLayout.minimumLineSpacing;

}

- (UICollectionViewLayoutAttributes *) centermostElementAttributesInRect:(CGRect)rect {
	
	CGPoint visualCenter = (CGPoint){
		CGRectGetMidX(rect),
		CGRectGetMidY(rect)
	};
	
	UICollectionView *collectionView = self.collectionView;
	
	CGFloat (^distance)(CGPoint, CGPoint) = ^ (CGPoint lhs, CGPoint rhs) {
		return sqrtf(powf(rhs.x - lhs.x, 2) + powf(rhs.y - lhs.y, 2));
	};
	
	NSArray *cellsByDistance = [[collectionView visibleCells] sortedArrayUsingComparator:^(UICollectionViewCell *lhs, UICollectionViewCell *rhs) {
		
		CGFloat lhsDistance = distance(lhs.center, visualCenter);
		CGFloat rhsDistance = distance(rhs.center, visualCenter);
		
		return (lhsDistance < rhsDistance) ?
			NSOrderedAscending :
			(lhsDistance > rhsDistance) ?
				NSOrderedDescending :
				NSOrderedSame;
		
	}];
	
	if (![cellsByDistance count])
		return nil;
	
	return [collectionView layoutAttributesForItemAtIndexPath:[self.collectionView indexPathForCell:[cellsByDistance lastObject]]];

}

- (void) pageCollectionView:(RAPageCollectionView *)pageCollectionView willChangeFromFrame:(CGRect)fromBounds toFrame:(CGRect)toBounds {

	self.collectionViewLayout.itemSize = self.view.bounds.size;

}

- (void) pageCollectionView:(RAPageCollectionView *)pageCollectionView didChangeFromFrame:(CGRect)fromBounds toFrame:(CGRect)toBounds {
	
	if (isnan(self.displayIndex))
		return;
	
	CALayer *referenceLayer = self.view.layer;
	CABasicAnimation *positionAnimation = (CABasicAnimation *)[referenceLayer animationForKey:@"position"];
	CABasicAnimation *boundsAnimation = (CABasicAnimation *)[referenceLayer animationForKey:@"bounds"];
	
	if (!positionAnimation || !boundsAnimation)
		return;
	
	NSTimeInterval duration = boundsAnimation.duration;
	UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState;
	
	NSUInteger lastIndex = (NSUInteger)roundf(self.displayIndex);
	UIViewController *viewController = [self.delegate viewControllerForPageAtIndex:lastIndex inPageCollectionViewController:self];
	
	if (viewController.parentViewController != self) {
		[self addChildViewController:viewController];
		[viewController didMoveToParentViewController:self];
	}
	
	[self.view addSubview:viewController.view];
	
	CGRect fromLayerBounds = (CGRect){
		CGPointZero,
		[[boundsAnimation fromValue] CGRectValue].size
	};
	CGPoint fromLayerPosition = (CGPoint){
		CGRectGetMidX(fromLayerBounds),
		CGRectGetMidY(fromLayerBounds)
	};
	
	NSOperation *animationOperation = [[RADeferredOperation alloc] initWithWorkerBlock:^(RADeferredOperation *operation, RADeferredOperationCompletionBlock completionBlock) {
		
		if ([operation isCancelled]) {
			completionBlock();
			return;
		}
		
		[viewController.view.layer removeAllAnimations];
		
		viewController.view.layer.position = fromLayerPosition;
		viewController.view.layer.bounds = fromLayerBounds;
		viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
				
		[viewController.view.layer removeAllAnimations];
		
		self.collectionView.hidden = YES;
		
		[UIView animateWithDuration:duration delay:0.0f options:options animations:^{
			
			viewController.view.frame = self.view.bounds;
			[self.view addSubview:viewController.view];
			NSCParameterAssert(viewController.view.superview == self.view);
			
		} completion:^(BOOL finished) {
			
			[self.view addSubview:viewController.view];
			NSCParameterAssert(viewController.view.superview == self.view);
			
			viewController.view.transform = CGAffineTransformIdentity;
			self.collectionView.hidden = NO;
			
			[viewController willMoveToParentViewController:nil];
			[viewController.view removeFromSuperview];
			[viewController removeFromParentViewController];
			
			if (!finished || [operation isCancelled]) {
				completionBlock();
				return;
			}
			
			[self setDisplayIndex:lastIndex animated:NO completion:nil];
			
			RAPageCollectionViewCell *cell = (RAPageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:lastIndex inSection:0]];
			
			cell.parentViewController = self;
			cell.childViewController = viewController;
			[cell setNeedsLayout];
			
			NSCParameterAssert(![operation isCancelled]);
			completionBlock();
							
		}];

	}];
	
	for (NSOperation *operation in self.animationQueue.operations)
		[animationOperation addDependency:operation];
	
	[self.animationQueue cancelAllOperations];
	[self.animationQueue addOperation:animationOperation];
	
}

- (void) pageCollectionViewDidLayout:(RAPageCollectionView *)pageCollectionView {

	//	no op

}

- (void) pageCollectionViewWillLayout:(RAPageCollectionView *)pageCollectionView {

	//	no op
		
}

- (CGFloat) displayIndexFromCurrentState {

	UICollectionView *pageCollectionView = self.collectionView;
	UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)pageCollectionView.collectionViewLayout;
	UICollectionViewLayoutAttributes *element = [self centermostElementAttributesInRect:pageCollectionView.bounds];
	
	if (!element) {
		
		return NAN;
		
	} else {
	
		CGPoint contentOffset = pageCollectionView.contentOffset;
		
		CALayer *presentationLayer = [pageCollectionView.layer presentationLayer];
		CGRect presentationBounds = presentationLayer.bounds;
		
		CGPoint elementCenter = element.center;
		CGFloat offset = (CGFloat)element.indexPath.item;
		
		switch (flowLayout.scrollDirection) {
			
			case UICollectionViewScrollDirectionHorizontal: {
				
				CGFloat pageBreadth = [self pageSpacing] + element.size.width;
				CGFloat containerBreadth = CGRectGetWidth(presentationBounds);
				CGFloat containerCenterOffset = contentOffset.x + 0.5f * containerBreadth;
				CGFloat elementCenterOffset = elementCenter.x;
				
				return offset + (containerCenterOffset - elementCenterOffset) / pageBreadth;
				
			}
			
			case UICollectionViewScrollDirectionVertical: {
				
				CGFloat pageBreadth = [self pageSpacing] + element.size.height;
				CGFloat containerBreadth = CGRectGetHeight(presentationBounds);
				CGFloat containerCenterOffset = contentOffset.y + 0.5f * containerBreadth;
				CGFloat elementCenterOffset = elementCenter.y;
				
				return offset + (containerCenterOffset - elementCenterOffset) / pageBreadth;
				
			}
			
		}
	
	}

}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {

	if ([scrollView isTracking] || [scrollView isDecelerating]) {
	
		[self captureDisplayIndex];
	
	}

}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

	if (!decelerate)
		[self captureLastIndexPath];

	[self captureDisplayIndex];
	
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

	[self captureLastIndexPath];
	[self captureDisplayIndex];

}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

	[[NSNotificationCenter defaultCenter] postNotificationName:RAPageCollectionViewDidEndScrollAnimationNotification object:scrollView];

}

- (void) captureLastIndexPath {

	self.lastIndexPath = [self centermostElementAttributesInRect:self.collectionView.bounds].indexPath;
	
}

- (void) captureDisplayIndex {

	[self willChangeValueForKey:@"displayIndex"];
	_displayIndex = [self displayIndexFromCurrentState];
	[self didChangeValueForKey:@"displayIndex"];

}

- (void) setDisplayIndex:(CGFloat)displayIndex {

	[self setDisplayIndex:displayIndex animated:NO completion:nil];

}

- (void) setDisplayIndex:(CGFloat)displayIndex animated:(BOOL)animate completion:(void(^)(void))completionBlock {

	CGPoint toContentOffset = CGPointZero;
	CGFloat pageBreadth = NAN;
	
	UICollectionViewFlowLayout *layout = self.collectionViewLayout;
	switch (layout.scrollDirection) {
		
		case UICollectionViewScrollDirectionHorizontal: {
			pageBreadth = layout.itemSize.width + [self pageSpacing];
			toContentOffset = (CGPoint) { .x = displayIndex * pageBreadth };
			break;
		}
		
		case UICollectionViewScrollDirectionVertical: {
			pageBreadth = layout.itemSize.height + [self pageSpacing];
			toContentOffset = (CGPoint) { .y = displayIndex * pageBreadth };
			break;
		}
		
	}
	
	if (_displayIndex != displayIndex) {
		[self willChangeValueForKey:@"displayIndex"];
		_displayIndex = displayIndex;
		[self didChangeValueForKey:@"displayIndex"];
	}
	
	if (animate) {
		
		[UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionLayoutSubviews animations:^{
			
			UICollectionView *collectionView = self.collectionView;
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			
			__block __unsafe_unretained id observer = [notificationCenter addObserverForName:RAPageCollectionViewDidEndScrollAnimationNotification object:collectionView queue:nil usingBlock:^(NSNotification *note) {
				
				NSCParameterAssert(observer);
				
				if (completionBlock)
					completionBlock();
				
				[notificationCenter removeObserver:observer];
				
			}];
			
			[self.collectionView setContentOffset:toContentOffset animated:YES];
			
		} completion:nil];
	
	} else {
	
		[self.collectionView setContentOffset:toContentOffset];		
	
		if (completionBlock)
			completionBlock();
		
	}
	
}

- (void) exhaustLastCentermostElement {
		
	NSIndexPath *lastIndexPath = self.lastIndexPath;
	NSUInteger toIndex = lastIndexPath ?
		lastIndexPath.item :
		([self.collectionView numberOfItemsInSection:0] ?
			0 :
			NAN);
	
	if (!isnan(toIndex))
		[self setDisplayIndex:(CGFloat)toIndex animated:NO completion:nil];
	
}

- (BOOL) pageCollectionViewCell:(RAPageCollectionViewCell *)cell shouldMoveChildViewFromView:(UIView *)fromSuperview toView:(UIView *)toSuperview {

	if (fromSuperview == self.view)
	if (toSuperview != self.view)
	if (fromSuperview != toSuperview) {
	
		return NO;
	
	}
	
	if (cell.childViewController.view.superview == self.view)
		return NO;
	
	return YES;

}

- (BOOL) pageCollectionViewCell:(RAPageCollectionViewCell *)cell shouldChangeChildViewFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame {

	return YES;

}

- (NSOperationQueue *) animationQueue {

	if (!_animationQueue) {
	
		_animationQueue = [[NSOperationQueue alloc] init];
		_animationQueue.maxConcurrentOperationCount = 1;
	
	}
	
	return _animationQueue;

}

@end
