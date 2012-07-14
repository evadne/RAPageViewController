//
//  IRPageViewController.h
//  IRPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "IRPageViewControllerDelegate.h"


@interface IRPageViewController : UIViewController

@property (nonatomic, readwrite, weak) IBOutlet id<IRPageViewControllerDelegate> delegate;
@property (nonatomic, readwrite, strong) IBOutletCollection(UIViewController) NSArray *viewControllers;

@end
