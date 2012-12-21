//
//  RAPageViewControllerDelegate.h
//  RAPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RAPageViewController;
@protocol RAPageViewControllerDelegate <NSObject>

- (UIViewController *) pageViewController:(RAPageViewController *)pvc viewControllerBeforeViewController:(UIViewController *)vc;
- (UIViewController *) pageViewController:(RAPageViewController *)pvc viewControllerAfterViewController:(UIViewController *)vc;

@end
