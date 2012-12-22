//
//  RAPageViewController.m
//  RAPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAPageViewController.h"
#import "RAPageViewControllerSubclass.h"

@interface RAPageViewController ()
@property (nonatomic, readwrite, weak) UIViewController *lastVisibleViewController;
@end

@implementation RAPageViewController
@synthesize delegate = _delegate;
@synthesize scrollView = _scrollView;
@synthesize currentPageViewController = _currentPageViewController;
@synthesize previousPageViewController = _previousPageViewController;
@synthesize nextPageViewController = _nextPageViewController;
@synthesize currentPageViewContainer = _currentPageViewContainer;
@synthesize previousPageViewContainer = _previousPageViewContainer;
@synthesize nextPageViewContainer = _nextPageViewContainer;
@synthesize lastVisibleViewController = _lastVisibleViewController;

- (void) viewDidLoad {

	[super viewDidLoad];
	[self.view addSubview:self.scrollView];
	
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

- (RAPageViewControllerScrollView *) scrollView {

	if (!_scrollView) {
	
		_scrollView = [[RAPageViewControllerScrollView alloc] initWithFrame:self.view.bounds];
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

- (void) pageViewControllerScrollViewDidLayoutSubviews:(RAPageViewControllerScrollView *)pvcSV {

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
	
	__block CGPoint toContentOffset = fromContentOffset;
	
	[self locateClosestPageOnPrevious:^{
		
		UIViewController *previousVC = [self.delegate pageViewController:self viewControllerBeforeViewController:self.previousPageViewController];
		
		if (previousVC != self.previousPageViewController) {
		
			self.nextPageViewController = self.currentPageViewController;
			self.currentPageViewController = self.previousPageViewController;
			self.previousPageViewController = previousVC;
		
			toContentOffset = (CGPoint){
				fromContentOffset.x + (CGRectGetMidX(currentViewRect) - CGRectGetMidX(previousViewRect)),
				fromContentOffset.y + (CGRectGetMidY(currentViewRect) - CGRectGetMidY(previousViewRect))
			};
			
			[self willChangeValueForKey:@"viewControllers"];
			_viewControllers = @[ self.currentPageViewController ];
			[self didChangeValueForKey:@"viewControllers"];
			
		}
		
	} onCurrent:^{
		
		//	no op
		
	} onNext:^{
		
		UIViewController *nextVC = [self.delegate pageViewController:self viewControllerAfterViewController:self.nextPageViewController];
		
		if (nextVC != self.nextPageViewController) {
		
			self.previousPageViewController = self.currentPageViewController;
			self.currentPageViewController = self.nextPageViewController;
			self.nextPageViewController = nextVC;
			
			toContentOffset = (CGPoint){
				fromContentOffset.x - (CGRectGetMidX(nextViewRect) - CGRectGetMidX(currentViewRect)),
				fromContentOffset.y - (CGRectGetMidY(nextViewRect) - CGRectGetMidY(currentViewRect))
			};
			
			[self willChangeValueForKey:@"viewControllers"];
			_viewControllers = @[ self.currentPageViewController ];
			[self didChangeValueForKey:@"viewControllers"];
		
		}
		
	}];
	
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
	previousPVCVContainer.hidden = !previousPVCView;
	previousPVCView.frame = previousPVCVContainer.bounds;
	[previousPVCVContainer addSubview:previousPVCView];
	[sv addSubview:previousPVCVContainer];
	
	currentPVCVContainer.frame = currentViewRect;
	currentPVCVContainer.hidden = !currentPVCView;
	currentPVCView.frame = currentPVCVContainer.bounds;
	[currentPVCVContainer addSubview:currentPVCView];
	[sv addSubview:currentPVCVContainer];
	
	nextPVCVContainer.frame = nextViewRect;
	nextPVCVContainer.hidden = !nextPVCView;
	nextPVCView.frame = nextPVCVContainer.bounds;
	[nextPVCVContainer addSubview:nextPVCView];
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

- (void) locateClosestPageOnPrevious:(void(^)(void))previousBlock onCurrent:(void(^)(void))currentBlock onNext:(void(^)(void))nextBlock {

	CGRect previousPageRect = [self previousPageRect];
	CGRect currentPageRect = [self currentPageRect];
	CGRect nextPageRect = [self nextPageRect];
	
	CGPoint contentOffset = self.scrollView.contentOffset;
	
	CGPoint (^center)(CGRect) = ^ (CGRect rect) {
		return (CGPoint){
			CGRectGetMidX(rect),
			CGRectGetMidY(rect)
		};
	};
	
	CGFloat (^distance)(CGPoint, CGPoint) = ^ (CGPoint lhs, CGPoint rhs) {
		return sqrtf(
			powf(lhs.x - rhs.x, 2) +
			powf(lhs.y - rhs.y, 2)
		);
	};
	
	CGPoint previousPageRectCenter = center(previousPageRect);
	CGPoint currentPageRectCenter = center(currentPageRect);
	CGPoint nextPageRectCenter = center(nextPageRect);
	
	CGPoint targetContentOffsetCenter = (CGPoint){
		contentOffset.x + 0.5f * CGRectGetWidth(self.scrollView.frame),
		contentOffset.y + 0.5f * CGRectGetHeight(self.scrollView.frame),
	};
	
	CGFloat previousPageRectCenterDistance = distance(previousPageRectCenter, targetContentOffsetCenter);
	CGFloat currentPageRectCenterDistance = distance(currentPageRectCenter,targetContentOffsetCenter);
	CGFloat nextPageRectCenterDistance = distance(nextPageRectCenter, targetContentOffsetCenter);
	
	CGFloat minPageRectCenterDistance = MIN(MIN(previousPageRectCenterDistance, currentPageRectCenterDistance), nextPageRectCenterDistance);
	
	if (previousPageRectCenterDistance == minPageRectCenterDistance) {

		if (previousBlock)
			previousBlock();
	
	} else if (nextPageRectCenterDistance == minPageRectCenterDistance) {
		
		if (nextBlock)
			nextBlock();
		
	} else {
	
		if (currentBlock)
			currentBlock();
		
	}

}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

	if (!decelerate) {
		[self.scrollView setNeedsLayout];
	}
	
	[[self class] attemptRotationToDeviceOrientation];

}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

	[self.scrollView setNeedsLayout];
	
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

	UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
	container.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	
	return container;

}

- (BOOL) shouldAutorotate {

	return !self.scrollView.tracking;

}

- (void) updateLastVisibleViewController {

	CGRect previousPageRect = [self previousPageRect];
	CGRect currentPageRect = [self currentPageRect];
	CGRect nextPageRect = [self nextPageRect];
	
	CGRect boundsRect = [self.scrollView convertRect:self.view.bounds fromView:self.view];
	
	CGFloat (^intersectionArea)(CGRect, CGRect) = ^ (CGRect lhs, CGRect rhs) {
		CGRect intersection =	CGRectIntersection(lhs, rhs);
		return CGRectEqualToRect(intersection, CGRectNull) ?
			0.0f :
			CGRectGetWidth(intersection) * CGRectGetHeight(intersection);
	};
	
	CGFloat previousPageArea = intersectionArea(boundsRect, previousPageRect);
	CGFloat currentPageArea = intersectionArea(boundsRect, currentPageRect);
	CGFloat nextPageArea = intersectionArea(boundsRect, nextPageRect);
	CGFloat maxPageArea = MAX(MAX(previousPageArea, currentPageArea), nextPageArea);
	
	if (previousPageArea == maxPageArea) {
		self.lastVisibleViewController = self.previousPageViewController;
	} else if (nextPageArea == maxPageArea) {
		self.lastVisibleViewController = self.nextPageViewController;
	} else {
		self.lastVisibleViewController = self.currentPageViewController;
	}
	
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	[self updateLastVisibleViewController];

}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	UIViewController *lastVisibleViewController = self.lastVisibleViewController;
	if (lastVisibleViewController == self.previousPageViewController) {
		[self.scrollView setContentOffset:[self previousPageRect].origin];
	} else if (lastVisibleViewController == self.nextPageViewController) {
		[self.scrollView setContentOffset:[self nextPageRect].origin];
	} else {
		[self.scrollView setContentOffset:[self currentPageRect].origin];
	}

}

@end
