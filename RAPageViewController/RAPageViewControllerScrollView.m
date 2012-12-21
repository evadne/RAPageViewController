//
//  RAPageViewControllerScrollView.m
//  RAPageViewController
//
//  Created by Evadne Wu on 7/15/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAPageViewControllerScrollView.h"

@implementation RAPageViewControllerScrollView
@dynamic delegate;

- (void) layoutSubviews {

	if ([self.delegate respondsToSelector:@selector(pageViewControllerScrollViewWillLayoutSubviews:)])
		[self.delegate pageViewControllerScrollViewWillLayoutSubviews:self];

	[super layoutSubviews];
	
	if ([self.delegate respondsToSelector:@selector(pageViewControllerScrollViewDidLayoutSubviews:)])
		[self.delegate pageViewControllerScrollViewDidLayoutSubviews:self];

}

@end
