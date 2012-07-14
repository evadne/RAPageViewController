//
//  IRPageViewControllerScrollViewDelegate.h
//  IRPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IRPageViewControllerScrollView;
@protocol IRPageViewControllerScrollViewDelegate <UIScrollViewDelegate>

@optional
- (void) pageViewControllerScrollViewWillLayoutSubviews:(IRPageViewControllerScrollView *)pvcSV;
- (void) pageViewControllerScrollViewDidLayoutSubviews:(IRPageViewControllerScrollView *)pvcSV;

@end
