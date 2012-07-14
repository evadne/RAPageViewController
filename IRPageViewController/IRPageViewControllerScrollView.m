//
//  IRPageViewControllerScrollView.m
//  IRPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRPageViewControllerScrollView.h"

@implementation IRPageViewControllerScrollView
@dynamic delegate;

- (void) layoutSubviews {

	if ([self.delegate respondsToSelector:@selector(pageViewControllerScrollViewWillLayoutSubviews:)])
		[self.delegate pageViewControllerScrollViewWillLayoutSubviews:self];

	[super layoutSubviews];
	
	if ([self.delegate respondsToSelector:@selector(pageViewControllerScrollViewDidLayoutSubviews:)])
		[self.delegate pageViewControllerScrollViewDidLayoutSubviews:self];

}

@end
