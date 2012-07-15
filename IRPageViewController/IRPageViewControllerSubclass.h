//
//  IRPageViewController_Sub.h
//  IRPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRPageViewController.h"
#import "IRPageViewControllerScrollView.h"
#import "IRPageViewControllerScrollViewDelegate.h"

@interface IRPageViewController () <IRPageViewControllerScrollViewDelegate>

@property (nonatomic, readonly, strong) IRPageViewControllerScrollView *scrollView;

@property (nonatomic, readwrite, strong) UIViewController *currentPageViewController;
@property (nonatomic, readwrite, strong) UIViewController *previousPageViewController;
@property (nonatomic, readwrite, strong) UIViewController *nextPageViewController;

@property (nonatomic, readonly, strong) UIView *currentPageViewContainer;
@property (nonatomic, readonly, strong) UIView *previousPageViewContainer;
@property (nonatomic, readonly, strong) UIView *nextPageViewContainer;

- (UIView *) newPageViewContainer;	//	override for custom overlay

- (CGRect) currentPageRect;
- (CGRect) previousPageRect;
- (CGRect) nextPageRect;

- (CGRect) viewRectForPageRect:(CGRect)rect;

@property (nonatomic, readwrite, assign) BOOL tiled;	//	FIXME
- (void) tile;	//	FIXME

@end
