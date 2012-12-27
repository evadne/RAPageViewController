//
//  RAPageCollectionViewCellDelegate.h
//  RAPageViewController
//
//  Created by Evadne Wu on 12/26/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RAPageCollectionViewCell;
@protocol RAPageCollectionViewCellDelegate <NSObject>

- (BOOL) pageCollectionViewCell:(RAPageCollectionViewCell *)cell shouldMoveChildViewFromView:(UIView *)fromSuperview toView:(UIView *)toSuperview;

- (BOOL) pageCollectionViewCell:(RAPageCollectionViewCell *)cell shouldChangeChildViewFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame;

@end
