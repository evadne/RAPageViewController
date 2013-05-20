//
//  RAPageViewController_Sub.h
//  RAPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAPageViewController.h"
#import "RAPageViewControllerScrollView.h"
#import "RAPageViewControllerScrollViewDelegate.h"

@interface RAPageViewController () <RAPageViewControllerScrollViewDelegate>

@property (nonatomic, readonly, strong) RAPageViewControllerScrollView *scrollView;

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

@end
