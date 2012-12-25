//
//  RAPageCollectionViewControllerDelegate.h
//  RAPageViewController
//
//  Created by Evadne Wu on 12/24/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RAPageCollectionViewController;
@protocol RAPageCollectionViewControllerDelegate <NSObject>

- (NSUInteger) numberOfViewControllersInPageCollectionViewController:(RAPageCollectionViewController *)pageCollectionViewController;

- (UIViewController *) viewControllerForPageAtIndex:(NSUInteger)index inPageCollectionViewController:(RAPageCollectionViewController *)pageCollectionViewController;

@end
