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

@interface RAPageCollectionViewController () <RAPageCollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

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
	
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

	return [self.delegate numberOfViewControllersInPageCollectionViewController:self];

}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	NSString * const identifier = @"Cell";
	RAPageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
	
	cell.backgroundColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.5f + 0.5f * ((float)indexPath.item / 256.0f)];
	
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

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

	if (scrollView != self.collectionView)
		return;
		
	if (CGPointEqualToPoint(CGPointZero, velocity))
		return;
	
	*targetContentOffset = [self centermostElementAttributesInRect:(CGRect){
		*targetContentOffset,
		self.collectionView.bounds.size
	}].frame.origin;

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
	
	[self exhaustLastCentermostElement];
	[pageCollectionView setNeedsLayout];
	[pageCollectionView layoutSubviews];
	
	UICollectionViewCell *currentCell = [self.collectionView cellForItemAtIndexPath:[self centermostElementAttributesInRect:self.collectionView.bounds].indexPath];
	[currentCell.superview bringSubviewToFront:currentCell];
	
	[pageCollectionView.layer removeAllAnimations];
	
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

- (void) exhaustLastCentermostElement {
		
	NSIndexPath *lastIndexPath = self.lastIndexPath;
	if (!lastIndexPath) {
		if (!![self.collectionView numberOfItemsInSection:0]) {
			lastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
		}
	}
		
	if (lastIndexPath) {
		
		UICollectionViewFlowLayout *layout = self.collectionViewLayout;
		CGPoint toContentOffset = CGPointZero;
				
		switch (layout.scrollDirection) {
			
			case UICollectionViewScrollDirectionHorizontal: {
				toContentOffset = (CGPoint) {
					lastIndexPath.item * (layout.itemSize.width + [self pageSpacing]),
					0.0f
				};
				break;
			}
			
			case UICollectionViewScrollDirectionVertical: {
				toContentOffset = (CGPoint) {
					0.0f,
					lastIndexPath.item * (layout.itemSize.height + [self pageSpacing])
				};
				break;
			}
			
		}
		
		[self.collectionView setContentOffset:toContentOffset animated:YES];
		
	}

}

@end
