//
//  IRPageViewController.m
//  IRPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRPageViewController.h"
#import "IRPageViewControllerSubclass.h"


@implementation IRPageViewController
@synthesize delegate = _delegate;
@synthesize scrollView = _scrollView;
@synthesize currentPageViewController = _currentPageViewController;
@synthesize previousPageViewController = _previousPageViewController;
@synthesize nextPageViewController = _nextPageViewController;
@synthesize currentPageViewContainer = _currentPageViewContainer;
@synthesize previousPageViewContainer = _previousPageViewContainer;
@synthesize nextPageViewContainer = _nextPageViewContainer;
@synthesize tiled = _tiled;

- (void) viewDidLoad {

	[super viewDidLoad];
	[self.view addSubview:self.scrollView];
	
	self.tiled = NO;
	if (self.viewControllers) {
		[self.scrollView setContentOffset:(CGPoint){
			CGRectGetMidX([self currentPageRect]),
			CGRectGetMidY([self currentPageRect])
		} animated:NO];
	}
	
}

- (void) setView:(UIView *)view {

	[super setView:view];
	
	if (!view) {
		
		_scrollView.delegate = nil;
		_scrollView = nil;
		
		_previousPageViewContainer = nil;
		_currentPageViewContainer = nil;
		_nextPageViewContainer = nil;
		
	}

}

- (IRPageViewControllerScrollView *) scrollView {

	if (!_scrollView) {
	
		_scrollView = [[IRPageViewControllerScrollView alloc] initWithFrame:self.view.bounds];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		_scrollView.delegate = self;
		_scrollView.pagingEnabled = YES;
		_scrollView.alwaysBounceHorizontal = NO;
		_scrollView.alwaysBounceVertical = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		
	}
	
	return _scrollView;

}

- (void) viewDidLayoutSubviews {

	[super viewDidLayoutSubviews];
	
	[self.scrollView setNeedsLayout];

}

- (void) pageViewControllerScrollViewDidLayoutSubviews:(IRPageViewControllerScrollView *)pvcSV {

	[self tile];

}

//	- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//		
//		if (scrollView.pagingEnabled)
//			return;
//		
//		CGRect previousPageRect = [self previousPageRect];
//		CGRect currentPageRect = [self currentPageRect];
//		CGRect nextPageRect = [self nextPageRect];
//		
//		CGPoint previousPageRectCenter = (CGPoint){
//			CGRectGetMidX(previousPageRect),
//			CGRectGetMidY(previousPageRect)
//		};
//		CGPoint currentPageRectCenter = (CGPoint){
//			CGRectGetMidX(currentPageRect),
//			CGRectGetMidY(currentPageRect)
//		};
//		CGPoint nextPageRectCenter = (CGPoint){
//			CGRectGetMidX(nextPageRect),
//			CGRectGetMidY(nextPageRect)
//		};
//		
//		CGPoint targetContentOffsetCenter = (CGPoint){
//			(*targetContentOffset).x + 0.5f * CGRectGetWidth(scrollView.frame),
//			(*targetContentOffset).y + 0.5f * CGRectGetHeight(scrollView.frame),
//		};
//		
//		CGFloat previousPageRectCenterDistance = sqrtf(
//			powf(previousPageRectCenter.x - targetContentOffsetCenter.x, 2) +
//			powf(previousPageRectCenter.y - targetContentOffsetCenter.y, 2)
//		);
//		CGFloat currentPageRectCenterDistance = sqrtf(
//			powf(currentPageRectCenter.x - targetContentOffsetCenter.x, 2) +
//			powf(currentPageRectCenter.y - targetContentOffsetCenter.y, 2)
//		);
//		CGFloat nextPageRectCenterDistance = sqrtf(
//			powf(nextPageRectCenter.x - targetContentOffsetCenter.x, 2) +
//			powf(nextPageRectCenter.y - targetContentOffsetCenter.y, 2)
//		);
//		
//		CGFloat minPageRectCenterDistance = MIN(MIN(previousPageRectCenterDistance, currentPageRectCenterDistance), nextPageRectCenterDistance);
//		
//		if (previousPageRectCenterDistance == minPageRectCenterDistance) {
//
//			*targetContentOffset = (CGPoint){
//				previousPageRectCenter.x - 0.5f * CGRectGetWidth(scrollView.frame),
//				previousPageRectCenter.y - 0.5f * CGRectGetHeight(scrollView.frame)
//			};
//		
//		} else if (nextPageRectCenterDistance == minPageRectCenterDistance) {
//			
//			*targetContentOffset = (CGPoint){
//				nextPageRectCenter.x - 0.5f * CGRectGetWidth(scrollView.frame),
//				nextPageRectCenter.y - 0.5f * CGRectGetHeight(scrollView.frame)
//			};
//			
//		} else {
//		
//			*targetContentOffset = (CGPoint){
//				currentPageRectCenter.x - 0.5f * CGRectGetWidth(scrollView.frame),
//				currentPageRectCenter.y - 0.5f * CGRectGetHeight(scrollView.frame)
//			};
//			
//		}
//
//	}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

	if (!decelerate) {
		[self.scrollView setNeedsLayout];
	}
	
	[[self class] attemptRotationToDeviceOrientation];

}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

	[self.scrollView setNeedsLayout];
	
	//	[self.scrollView layoutSubviews];
	//	
	//	CGPoint contentOffset = self.scrollView.contentOffset;
	//	
	//	CGRect const previousPageRect = [self previousPageRect];
	//	CGRect const currentPageRect = [self currentPageRect];
	//	CGRect const nextPageRect = [self nextPageRect];
	//	
	//	CGPoint contentCenterPoint = (CGPoint){
	//		contentOffset.x + 0.5f * CGRectGetWidth(self.scrollView.frame),
	//		contentOffset.y + 0.5f * CGRectGetHeight(self.scrollView.frame)
	//	};
	//	
	//	CGFloat previousPageCenterDistance = sqrtf(
	//		powf(contentCenterPoint.x - CGRectGetMidX(previousPageRect), 2) +
	//		powf(contentCenterPoint.y - CGRectGetMidY(previousPageRect), 2)
	//	);
	//	CGFloat currentPageCenterDistance = sqrtf(
	//		powf(contentCenterPoint.x - CGRectGetMidX(currentPageRect), 2) +
	//		powf(contentCenterPoint.y - CGRectGetMidY(currentPageRect), 2)
	//	);
	//	CGFloat nextPageCenterDistance = sqrtf(
	//		powf(contentCenterPoint.x - CGRectGetMidX(nextPageRect), 2) +
	//		powf(contentCenterPoint.y - CGRectGetMidY(nextPageRect), 2)
	//	);
	//	
	//	CGFloat minPageCenterDistance = MIN(MIN(previousPageCenterDistance, currentPageCenterDistance), nextPageCenterDistance);
	//	
	//	if (previousPageCenterDistance == minPageCenterDistance) {
	//		
	//		[self.scrollView setContentOffset:previousPageRect.origin animated:YES];
	//	
	//	} else if (nextPageCenterDistance == minPageCenterDistance) {
	//
	//		[self.scrollView setContentOffset:nextPageRect.origin animated:YES];
	//		
	//	} else {
	//	
	//		[self.scrollView setContentOffset:currentPageRect.origin animated:YES];
	//		
	//	}
	
}

- (CGRect) currentPageRect {

	CGRect const viewBounds = (CGRect){
		CGPointZero,
		self.scrollView.frame.size
	};
	
	return CGRectOffset(
		viewBounds,
		1.0f * CGRectGetWidth(viewBounds),
		0.0f * CGRectGetHeight(viewBounds)
	);

}

- (CGRect) previousPageRect {

	CGRect const viewBounds = (CGRect){
		CGPointZero,
		self.scrollView.frame.size
	};
	
	return CGRectOffset(
		viewBounds,
		0.0f * CGRectGetWidth(viewBounds),
		0.0f * CGRectGetHeight(viewBounds)
	);

}

- (CGRect) nextPageRect {

	CGRect const viewBounds = (CGRect){
		CGPointZero,
		self.scrollView.frame.size
	};
	
	return CGRectOffset(
		viewBounds,
		2.0f * CGRectGetWidth(viewBounds),
		0.0f * CGRectGetHeight(viewBounds)
	);

}

- (void) setPreviousPageViewController:(UIViewController *)toPreviousPageViewController {

	[_previousPageViewController willMoveToParentViewController:nil];
	[_previousPageViewController removeFromParentViewController];
	
	if ([_previousPageViewController isViewLoaded])
		[_previousPageViewController.view removeFromSuperview];

	_previousPageViewController = toPreviousPageViewController;

	if (_previousPageViewController) {

		[self addChildViewController:_previousPageViewController];
		
		if ([self isViewLoaded]) {
			[self.previousPageViewContainer addSubview:_previousPageViewController.view];
		}
		
		[_previousPageViewController didMoveToParentViewController:self];
	
	}
	
}

- (void) setCurrentPageViewController:(UIViewController *)toCurrentPageViewController {

	[_currentPageViewController willMoveToParentViewController:nil];
	[_currentPageViewController removeFromParentViewController];
	
	if ([_currentPageViewController isViewLoaded])
		[_currentPageViewController.view removeFromSuperview];

	_currentPageViewController = toCurrentPageViewController;

	if (_currentPageViewController) {

		[self addChildViewController:_currentPageViewController];
		
		if ([self isViewLoaded]) {
			[self.currentPageViewContainer addSubview:_currentPageViewController.view];
		}
		
		[_currentPageViewController didMoveToParentViewController:self];
	
	}
	
}

- (void) setNextPageViewController:(UIViewController *)toNextPageViewController {

	[_nextPageViewController willMoveToParentViewController:nil];
	[_nextPageViewController removeFromParentViewController];
	
	if ([_nextPageViewController isViewLoaded])
		[_nextPageViewController.view removeFromSuperview];

	_nextPageViewController = toNextPageViewController;

	if (_nextPageViewController) {

		[self addChildViewController:_nextPageViewController];
		
		if ([self isViewLoaded]) {
			[self.nextPageViewContainer addSubview:_nextPageViewController.view];
		}
		
		[_nextPageViewController didMoveToParentViewController:self];
	
	}
	
}

- (void) setViewControllers:(NSArray *)viewControllers {

	if (_viewControllers == viewControllers)
		return;
	
	NSCParameterAssert([viewControllers count] <= 1);
	
	self.previousPageViewController = nil;
	self.currentPageViewController = nil;
	self.nextPageViewController = nil;
	
	_viewControllers = viewControllers;
	
	UIViewController *currentVC = [_viewControllers lastObject];;
	
	self.currentPageViewController = currentVC;
	self.previousPageViewController = [self.delegate pageViewController:self viewControllerBeforeViewController:currentVC];
	self.nextPageViewController = [self.delegate pageViewController:self viewControllerAfterViewController:currentVC];
	
	[self.scrollView setNeedsLayout];

}

- (CGRect) viewRectForPageRect:(CGRect)rect {

	return rect;

}

- (UIView *) previousPageViewContainer {

	if (!_previousPageViewContainer)
		_previousPageViewContainer = [self newPageViewContainer];
	
	return _previousPageViewContainer;

}

- (UIView *) currentPageViewContainer {

	if (!_currentPageViewContainer)
		_currentPageViewContainer = [self newPageViewContainer];
	
	return _currentPageViewContainer;

}

- (UIView *) nextPageViewContainer {

	if (!_nextPageViewContainer)
		_nextPageViewContainer = [self newPageViewContainer];
	
	return _nextPageViewContainer;

}

- (UIView *) newPageViewContainer {

	return [[UIView alloc] initWithFrame:CGRectZero];

}

- (void) tile {

	if (![self isViewLoaded])
		return;
		
	UIScrollView * const sv = self.scrollView;
	CGPoint const fromContentOffset = sv.contentOffset;
	
	CGRect const previousPageRect = [self previousPageRect];
	CGRect const currentPageRect = [self currentPageRect];
	CGRect const nextPageRect = [self nextPageRect];

	CGRect const previousViewRect = [self viewRectForPageRect:previousPageRect];
	CGRect const currentViewRect = [self viewRectForPageRect:currentPageRect];
	CGRect const nextViewRect = [self viewRectForPageRect:nextPageRect];
	
	CGPoint toContentOffset = fromContentOffset;
	
	CGPoint contentCenterPoint = (CGPoint){
		fromContentOffset.x + 0.5f * CGRectGetWidth(self.scrollView.frame),
		fromContentOffset.y + 0.5f * CGRectGetHeight(self.scrollView.frame)
	};
	
	CGFloat previousPageCenterDistance = sqrtf(
		powf(contentCenterPoint.x - CGRectGetMidX(previousPageRect), 2) +
		powf(contentCenterPoint.y - CGRectGetMidY(previousPageRect), 2)
	);
	CGFloat currentPageCenterDistance = sqrtf(
		powf(contentCenterPoint.x - CGRectGetMidX(currentPageRect), 2) +
		powf(contentCenterPoint.y - CGRectGetMidY(currentPageRect), 2)
	);
	CGFloat nextPageCenterDistance = sqrtf(
		powf(contentCenterPoint.x - CGRectGetMidX(nextPageRect), 2) +
		powf(contentCenterPoint.y - CGRectGetMidY(nextPageRect), 2)
	);
	
	CGFloat minPageCenterDistance = MIN(MIN(previousPageCenterDistance, currentPageCenterDistance), nextPageCenterDistance);
	
	if (previousPageCenterDistance == minPageCenterDistance) {
	
		UIViewController *previousVC = [self.delegate pageViewController:self viewControllerBeforeViewController:self.previousPageViewController];
		
		if (previousVC) {
		
			self.nextPageViewController = self.currentPageViewController;
			self.currentPageViewController = self.previousPageViewController;
			self.previousPageViewController = previousVC;
		
			toContentOffset = (CGPoint){
				fromContentOffset.x + (CGRectGetMidX(currentViewRect) - CGRectGetMidX(previousViewRect)),
				fromContentOffset.y + (CGRectGetMidY(currentViewRect) - CGRectGetMidY(previousViewRect))
			};
			
		}			
	
	} else if (nextPageCenterDistance == minPageCenterDistance) {
	
		UIViewController *nextVC = [self.delegate pageViewController:self viewControllerAfterViewController:self.nextPageViewController];
		
		if (nextVC) {
		
			self.previousPageViewController = self.currentPageViewController;
			self.currentPageViewController = self.nextPageViewController;
			self.nextPageViewController = nextVC;
			
			toContentOffset = (CGPoint){
				fromContentOffset.x - (CGRectGetMidX(nextViewRect) - CGRectGetMidX(currentViewRect)),
				fromContentOffset.y - (CGRectGetMidY(nextViewRect) - CGRectGetMidY(currentViewRect))
			};
		
		}
		
	}
		
	//	if (CGPointEqualToPoint(fromContentOffset, toContentOffset)) {
	//		return;
	//	}
	
	UIViewController * const previousPVC = self.previousPageViewController;
	UIViewController * const currentPVC = self.currentPageViewController;
	UIViewController * const nextPVC = self.nextPageViewController;
	
	NSCParameterAssert(previousPVC != currentPVC);
	NSCParameterAssert(currentPVC != nextPVC);
	
	UIView * const previousPVCView = previousPVC.view;
	UIView * const currentPVCView = currentPVC.view;
	UIView * const nextPVCView = nextPVC.view;
	
	NSCParameterAssert(previousPVCView != currentPVCView);
	NSCParameterAssert(currentPVCView != nextPVCView);
	
	UIView * const previousPVCVContainer = self.previousPageViewContainer;
	UIView * const currentPVCVContainer = self.currentPageViewContainer;
	UIView * const nextPVCVContainer = self.nextPageViewContainer;
	
	previousPVCVContainer.frame = previousViewRect;
	currentPVCVContainer.frame = currentViewRect;
	nextPVCVContainer.frame = nextViewRect;
	
	previousPVCView.frame = previousPVCVContainer.bounds;
	[previousPVCVContainer addSubview:previousPVCView];
	
	currentPVCView.frame = currentPVCVContainer.bounds;
	[currentPVCVContainer addSubview:currentPVCView];
	
	nextPVCView.frame = nextPVCVContainer.bounds;
	[nextPVCVContainer addSubview:nextPVCView];
	
	[sv addSubview:previousPVCVContainer];
	[sv addSubview:currentPVCVContainer];
	[sv addSubview:nextPVCVContainer];
	
	if (!CGPointEqualToPoint(sv.contentOffset, toContentOffset)) {
		[sv setContentOffset:toContentOffset];
	}
	
	CGRect contentRect = CGRectUnion(CGRectUnion(CGRectUnion(CGRectZero, previousPageRect), currentPageRect), nextPageRect);
	if (!CGSizeEqualToSize(sv.contentSize, contentRect.size)) {
		[sv setContentSize:contentRect.size];
	}
	
	UIEdgeInsets contentInset = (UIEdgeInsets){
		-1.0f * (previousPVCView ? 0.0f : CGRectGetMinY(currentPageRect)),
		-1.0f * (previousPVCView ? 0.0f : CGRectGetMinX(currentPageRect)),
		-1.0f * (nextPVCView ? 0.0f : (CGRectGetHeight(contentRect) - CGRectGetMaxY(currentPageRect))),
		-1.0f * (nextPVCView ? 0.0f : (CGRectGetWidth(contentRect) - CGRectGetMaxX(currentPageRect))),
	};
	
	if (!UIEdgeInsetsEqualToEdgeInsets(sv.contentInset, contentInset)) {
		[sv setContentInset:contentInset];
	}
	
}

- (BOOL) shouldAutorotate {

	return !self.scrollView.tracking;

}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	[self.scrollView setContentOffset:[self currentPageRect].origin];

}

@end
