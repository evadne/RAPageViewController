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

- (void) setFrame:(CGRect)frame {

	CGRect fromFrame = self.frame;
	CGRect toFrame = frame;
	
	if ([self.delegate respondsToSelector:@selector(pageViewControllerScrollViewDidChangeFromFrame:toFrame:)])
		[self.delegate pageViewControllerScrollViewWillChangeFromFrame:fromFrame toFrame:toFrame];

	[super setFrame:frame];
	
	if ([self.delegate respondsToSelector:@selector(pageViewControllerScrollViewDidChangeFromFrame:toFrame:)])
		[self.delegate pageViewControllerScrollViewDidChangeFromFrame:fromFrame toFrame:self.frame];

}

- (void) layoutSubviews {

	if ([self.delegate respondsToSelector:@selector(pageViewControllerScrollViewWillLayoutSubviews:)])
		[self.delegate pageViewControllerScrollViewWillLayoutSubviews:self];

	[super layoutSubviews];
	
	if ([self.delegate respondsToSelector:@selector(pageViewControllerScrollViewDidLayoutSubviews:)])
		[self.delegate pageViewControllerScrollViewDidLayoutSubviews:self];

}

@end
