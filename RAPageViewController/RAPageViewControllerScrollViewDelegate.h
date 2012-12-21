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
- (void) pageViewControllerScrollViewWillLayoutSubviews:(RAPageViewControllerScrollView *)pvcSV;
- (void) pageViewControllerScrollViewDidLayoutSubviews:(RAPageViewControllerScrollView *)pvcSV;

@end
