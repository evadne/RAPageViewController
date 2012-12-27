//
//  RAPageCollectionViewCell.h
//  RAPageViewController
//
//  Created by Evadne Wu on 12/24/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAPageCollectionViewCellDelegate.h"

@interface RAPageCollectionViewCell : UICollectionViewCell

@property (nonatomic, readwrite, weak) id<RAPageCollectionViewCellDelegate> delegate;

@property (nonatomic, readwrite, weak) UIViewController *parentViewController;
@property (nonatomic, readwrite, weak) UIViewController *childViewController;

@end
