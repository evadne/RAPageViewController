//
//  RAPageViewControllerScrollViewDelegate.h
//  RAPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RAPageViewControllerScrollView;
@protocol RAPageViewControllerScrollViewDelegate <UIScrollViewDelegate>

@optional
- (void) pageViewControllerScrollViewWillChangeFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame;
- (void) pageViewControllerScrollViewDidChangeFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame;
- (void) pageViewControllerScrollViewWillLayoutSubviews:(RAPageViewControllerScrollView *)pvcSV;
- (void) pageViewControllerScrollViewDidLayoutSubviews:(RAPageViewControllerScrollView *)pvcSV;

@end
