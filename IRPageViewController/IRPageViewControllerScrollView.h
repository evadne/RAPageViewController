//
//  IRPageViewControllerScrollView.h
//  IRPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IRPageViewControllerScrollViewDelegate.h"

@interface IRPageViewControllerScrollView : UIScrollView

@property (nonatomic, assign) id <IRPageViewControllerScrollViewDelegate> delegate;
//	Note: UIScrollView header says it’s a weak reference, need to vet veracity

@end
