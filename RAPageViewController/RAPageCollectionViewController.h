//
//  RAPageCollectionViewController.h
//  RAPageViewController
//
//  Created by Evadne Wu on 12/24/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAPageCollectionViewControllerDelegate.h"

@interface RAPageCollectionViewController : UIViewController

@property (nonatomic, readwrite, weak) id<RAPageCollectionViewControllerDelegate> delegate;

@property (nonatomic, readonly, strong) UICollectionView *collectionView;
@property (nonatomic, readonly, strong) UICollectionViewFlowLayout *collectionViewLayout;

@property (nonatomic, readwrite, assign) CGFloat displayIndex;	//	if no pages, it’ll be NAN, use isnan()
- (void) setDisplayIndex:(CGFloat)displayIndex animated:(BOOL)animate completion:(void(^)(void))completionBlock;

@end
