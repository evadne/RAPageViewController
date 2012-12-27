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

@interface RAPageCollectionViewController () <RAPageCollectionViewCellDelegate, RAPageCollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, readwrite, strong) NSIndexPath *lastIndexPath;

@end

@implementation RAPageCollectionViewController
@synthesize collectionView = _collectionView;
@synthesize collectionViewLayout = _collectionViewLayout;
@synthesize lastIndexPath = _lastIndexPath;

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

	NSString * const identifier = @"Cell";
	RAPageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
	
	cell.backgroundColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.5f + 0.5f * ((float)indexPath.item / 256.0f)];
	
	cell.delegate = self;
	cell.parentViewController = self;
	cell.childViewController = [self.delegate viewControllerForPageAtIndex:indexPath.item inPageCollectionViewController:self];
	
	cell.layer.borderColor = [UIColor redColor].CGColor;
	cell.layer.borderWidth = 2.0f;
	
	return cell;

}

- (UICollectionView *) collectionView {

	if (!_collectionView) {
	
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
				
		[_collectionView registerClass:[RAPageCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
		
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
//		_collectionViewLayout.itemSize = self.view.bounds.size;
		_collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		_collectionViewLayout.headerReferenceSize = (CGSize){ 8, 8 };
		_collectionViewLayout.footerReferenceSize = (CGSize){ 8, 8 };
				
	}
	
	return _collectionViewLayout;

}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

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

	CALayer *referenceLayer = self.view.layer;
	CABasicAnimation *positionAnimation = (CABasicAnimation *)[referenceLayer animationForKey:@"position"];
	CABasicAnimation *boundsAnimation = (CABasicAnimation *)[referenceLayer animationForKey:@"bounds"];
	
	if (!positionAnimation || !boundsAnimation)
		return;
	
	NSTimeInterval duration = boundsAnimation.duration;
	UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionOverrideInheritedDuration;
	
	UIViewController *viewController = [self.delegate viewControllerForPageAtIndex:self.lastIndexPath.item inPageCollectionViewController:self];
	
	if (viewController.parentViewController != self) {
		[self addChildViewController:viewController];
		[viewController didMoveToParentViewController:self];
	}
	
	UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
	overlayView.backgroundColor = [UIColor blackColor];
	
	[self.view addSubview:overlayView];
	[self.view addSubview:viewController.view];
	
	CGRect fromLayerBounds = (CGRect){
		CGPointZero,
		[[boundsAnimation fromValue] CGRectValue].size
	};
	CGPoint fromLayerPosition = (CGPoint){
		CGRectGetMidX(fromLayerBounds),
		CGRectGetMidY(fromLayerBounds)
	};
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		[viewController.view.layer removeAllAnimations];
		
		viewController.view.layer.position = fromLayerPosition;
		viewController.view.layer.bounds = fromLayerBounds;
		viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
				
		overlayView.layer.position = fromLayerPosition;
		overlayView.layer.bounds = fromLayerBounds;
		overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		
		[viewController.view.layer removeAllAnimations];
		
		[UIView animateWithDuration:duration delay:0.0f options:options animations:^{
			
			viewController.view.frame = self.view.bounds;
			overlayView.frame = self.view.bounds;
			
			NSCParameterAssert(viewController.view.superview == self.view);
			NSCParameterAssert(overlayView.superview == self.view);
			
		} completion:^(BOOL finished) {
			
			viewController.view.transform = CGAffineTransformIdentity;
			
			[viewController willMoveToParentViewController:nil];
			[viewController.view removeFromSuperview];
			[viewController removeFromParentViewController];
			
			[overlayView removeFromSuperview];
			
			[self exhaustLastCentermostElement];
			
			RAPageCollectionViewCell *cell = (RAPageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.lastIndexPath];
			
			cell.parentViewController = self;
			cell.childViewController = viewController;
			[cell setNeedsLayout];
			
		}];
	
	});
		
}

- (void) pageCollectionViewWillLayout:(RAPageCollectionView *)pageCollectionView {

	//	no op

}

- (void) pageCollectionViewDidLayout:(RAPageCollectionView *)pageCollectionView {

	UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)pageCollectionView.collectionViewLayout;
	UICollectionViewLayoutAttributes *element = [self centermostElementAttributesInRect:pageCollectionView.bounds];
	
	if (!element) {
		
		[self willChangeValueForKey:@"displayIndex"];
		_displayIndex = NAN;
		[self didChangeValueForKey:@"displayIndex"];
		
	} else {
	
		CGFloat pageBreadth = [self pageSpacing] + element.size.width;
		CGPoint elementCenter = element.center;
			
		CGFloat offset = 0.0f;
		
		switch (flowLayout.scrollDirection) {
			
			case UICollectionViewScrollDirectionHorizontal: {
				offset = ((pageCollectionView.contentOffset.x + 0.5f * CGRectGetWidth(pageCollectionView.bounds)) - elementCenter.x) / pageBreadth;
				break;
			}
			
			case UICollectionViewScrollDirectionVertical: {
				offset = ((pageCollectionView.contentOffset.y + 0.5f * CGRectGetHeight(pageCollectionView.bounds)) - elementCenter.y) / pageBreadth;
				break;
			}
			
		}
		
		[self willChangeValueForKey:@"displayIndex"];
		_displayIndex = offset + (CGFloat)element.indexPath.item;
		[self didChangeValueForKey:@"displayIndex"];
	
	}

}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

	if (!decelerate)
		[self captureLastIndexPath];

}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

	[self captureLastIndexPath];

}

- (void) captureLastIndexPath {

	self.lastIndexPath = [self centermostElementAttributesInRect:self.collectionView.bounds].indexPath;
	
}

- (void) setDisplayIndex:(CGFloat)displayIndex {

	[self setDisplayIndex:displayIndex animated:NO completion:nil];

}

- (void) setDisplayIndex:(CGFloat)displayIndex animated:(BOOL)animate completion:(void(^)(void))completionBlock {

	if (_displayIndex == displayIndex) {
		if (completionBlock)
			completionBlock();
		return;
	}
	
	NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
	NSCParameterAssert(displayIndex < numberOfItems);
	
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
	
	[self willChangeValueForKey:@"displayIndex"];
	_displayIndex = displayIndex;
	[self didChangeValueForKey:@"displayIndex"];
	
	if (animate) {

		[UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionLayoutSubviews animations:^{
			
			[self.collectionView setContentOffset:toContentOffset animated:YES];
			
		} completion:^(BOOL finished) {

			if (completionBlock)
				completionBlock();
			
		}];
	
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
	
	return YES;

}

- (BOOL) pageCollectionViewCell:(RAPageCollectionViewCell *)cell shouldChangeChildViewFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame {

	return YES;

}

@end
