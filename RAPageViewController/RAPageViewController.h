//
//  RAPageViewController.h
//  RAPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "RAPageViewControllerDelegate.h"


@interface RAPageViewController : UIViewController

@property (nonatomic, readwrite, weak) IBOutlet id<RAPageViewControllerDelegate> delegate;
@property (nonatomic, readwrite, strong) IBOutletCollection(UIViewController) NSArray *viewControllers;
@property (nonatomic) CGFloat contentOffsetIncrementX, contentOffsetIncrementY;

@end
