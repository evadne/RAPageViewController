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
	
	[self tile];

}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

	if (!decelerate) {
		self.tiled = NO;
		[self tile];
	}

}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

	self.tiled = NO;
	[self tile];

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

	NSCParameterAssert([viewControllers count] <= 1);
	
	self.previousPageViewController = nil;
	self.currentPageViewController = nil;
	self.nextPageViewController = nil;
	
	_viewControllers = viewControllers;
	
	UIViewController *currentVC = [_viewControllers lastObject];;
	
	self.currentPageViewController = currentVC;
	self.previousPageViewController = [self.delegate pageViewController:self viewControllerBeforeViewController:currentVC];
	self.nextPageViewController = [self.delegate pageViewController:self viewControllerAfterViewController:currentVC];

	[self tile];

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
	
	CGPoint const currentOffset = sv.contentOffset;
	CGRect const previousPageRect = [self previousPageRect];
	CGRect const currentPageRect = [self currentPageRect];
	CGRect const nextPageRect = [self nextPageRect];
	
	if (!self.tiled) {
	
		CGPoint (^center)(CGRect) = ^ (CGRect rect) {
			return (CGPoint){ CGRectGetMidX(rect), CGRectGetMidY(rect) };
		};
		
		CGFloat (^distance)(CGPoint, CGPoint) = ^ (CGPoint lhs, CGPoint rhs) {
			return sqrtf(powf(lhs.x - rhs.x, 2) + powf(lhs.y - rhs.y, 2));
		};
		
		CGPoint const offsetCenter = (CGPoint) {
			currentOffset.x + 0.5f * CGRectGetWidth(sv.frame),
			currentOffset.y + 0.5f * CGRectGetHeight(sv.frame),
		};
		
		CGFloat const previousCenterDistance = distance(offsetCenter, center(previousPageRect));
		CGFloat const currentCenterDistance = distance(offsetCenter, center(currentPageRect));
		CGFloat const nextCenterDistance = distance(offsetCenter, center(nextPageRect));
		CGFloat const minDistance = MIN(MIN(previousCenterDistance, currentCenterDistance), nextCenterDistance);
		
		if (minDistance == currentCenterDistance) {
		
			//	no op
		
		} else if (minDistance == previousCenterDistance) {
				
			self.nextPageViewController = self.currentPageViewController;
			self.currentPageViewController = self.previousPageViewController;
			self.previousPageViewController = [self.delegate pageViewController:self viewControllerBeforeViewController:self.currentPageViewController];

		} else if (minDistance == nextCenterDistance) {
		
			self.previousPageViewController = self.currentPageViewController;
			self.currentPageViewController = self.nextPageViewController;
			self.nextPageViewController = [self.delegate pageViewController:self viewControllerAfterViewController:self.currentPageViewController];
		
		}
		
		self.tiled = YES;
	
	}
	
	//	offset?  determine and swizzle
	
	
	UIViewController * const previousPVC = self.previousPageViewController;
	UIViewController * const currentPVC = self.currentPageViewController;
	UIViewController * const nextPVC = self.nextPageViewController;
	
	UIView * const previousPVCView = previousPVC.view;
	UIView * const currentPVCView = currentPVC.view;
	UIView * const nextPVCView = nextPVC.view;
	
	UIView * const previousPVCVContainer = self.previousPageViewContainer;
	UIView * const currentPVCVContainer = self.currentPageViewContainer;
	UIView * const nextPVCVContainer = self.nextPageViewContainer;
	
	previousPVCVContainer.frame = [self viewRectForPageRect:previousPageRect];
	currentPVCVContainer.frame = [self viewRectForPageRect:currentPageRect];
	nextPVCVContainer.frame = [self viewRectForPageRect:nextPageRect];
	
	previousPVCView.frame = previousPVCVContainer.bounds;
	[previousPVCVContainer addSubview:previousPVCView];
	
	currentPVCView.frame = currentPVCVContainer.bounds;
	[currentPVCVContainer addSubview:currentPVCView];
	
	nextPVCView.frame = nextPVCVContainer.bounds;
	[nextPVCVContainer addSubview:nextPVCView];
	
	[sv addSubview:previousPVCVContainer];
	[sv addSubview:currentPVCVContainer];
	[sv addSubview:nextPVCVContainer];
	
	CGPoint currentPageOrigin = (CGPoint){ CGRectGetMinX(currentPageRect), CGRectGetMinY(currentPageRect) };
	CGRect contentRect = CGRectUnion(CGRectUnion(CGRectUnion(CGRectZero, previousPageRect), currentPageRect), nextPageRect);
	
	[sv setContentOffset:currentPageOrigin animated:NO];
	[sv setContentSize:contentRect.size];
	
	UIEdgeInsets contentInset = (UIEdgeInsets){
		-1.0f * (previousPVCView ? 0.0f : CGRectGetMinY(currentPageRect)),
		-1.0f * (previousPVCView ? 0.0f : CGRectGetMinX(currentPageRect)),
		-1.0f * (nextPVCView ? 0.0f : (CGRectGetHeight(contentRect) - CGRectGetMaxY(currentPageRect))),
		-1.0f * (nextPVCView ? 0.0f : (CGRectGetWidth(contentRect) - CGRectGetMaxX(currentPageRect))),
	};
	
	[sv setContentInset:contentInset];

}

@end
