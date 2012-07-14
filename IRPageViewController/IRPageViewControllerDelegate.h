//
//  IRPageViewControllerDelegate.h
//  IRPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IRPageViewController;
@protocol IRPageViewControllerDelegate <NSObject>

- (UIViewController *) pageViewController:(IRPageViewController *)pvc viewControllerBeforeViewController:(UIViewController *)vc;
- (UIViewController *) pageViewController:(IRPageViewController *)pvc viewControllerAfterViewController:(UIViewController *)vc;

@end
