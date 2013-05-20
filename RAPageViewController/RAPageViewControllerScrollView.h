//
//  RAPageViewControllerScrollView.h
//  RAPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RAPageViewControllerScrollViewDelegate.h"

@interface RAPageViewControllerScrollView : UIScrollView

@property (nonatomic, assign) id <RAPageViewControllerScrollViewDelegate> delegate;
//	Note: UIScrollView header says it’s a weak reference, need to vet veracity

@end
