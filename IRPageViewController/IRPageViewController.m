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
			[self.view addSubview:_previousPageViewController.view];
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
			[self.view addSubview:_currentPageViewController.view];
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
			[self.view addSubview:_nextPageViewController.view];
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

- (void) tile {

	if (![self isViewLoaded])
		return;
	
	UIScrollView * const sv = self.scrollView;
	
	CGPoint const currentOffset = sv.contentOffset;
	CGRect const previousPageRect = [self previousPageRect];
	CGRect const currentPageRect = [self currentPageRect];
	CGRect const nextPageRect = [self nextPageRect];
	
	if (!self.tiled) {
	
		if (CGRectContainsPoint(previousPageRect, currentOffset)) {
		
			self.nextPageViewController = self.currentPageViewController;
			self.currentPageViewController = self.previousPageViewController;
			self.previousPageViewController = [self.delegate pageViewController:self viewControllerBeforeViewController:self.currentPageViewController];

		} else if (CGRectContainsPoint(nextPageRect, currentOffset)) {
		
			self.previousPageViewController = self.currentPageViewController;
			self.currentPageViewController = self.nextPageViewController;
			self.nextPageViewController = [self.delegate pageViewController:self viewControllerAfterViewController:self.currentPageViewController];
		
		} else {
		
			//	No op
		
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
	
	previousPVCView.frame = [self viewRectForPageRect:previousPageRect];
	currentPVCView.frame = [self viewRectForPageRect:currentPageRect];
	nextPVCView.frame = [self viewRectForPageRect:nextPageRect];
	
	[sv addSubview:previousPVCView];
	[sv addSubview:currentPVCView];
	[sv addSubview:nextPVCView];
	
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
