//
//  RAPageCollectionViewCell.m
//  RAPageViewController
//
//  Created by Evadne Wu on 12/24/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAPageCollectionViewCell.h"

@implementation RAPageCollectionViewCell

- (NSString *) description {

	return [NSString stringWithFormat:@"%@ { Parent: %@, Child: %@ }", [super description], self.parentViewController, self.childViewController];

}

- (void) setParentViewController:(UIViewController *)parentViewController {

	if (_parentViewController == parentViewController)
		return;
	
	[_childViewController willMoveToParentViewController:_parentViewController];
	[_childViewController removeFromParentViewController];
	
	if ([_childViewController isViewLoaded])
	if ([_childViewController.view isDescendantOfView:self])
		[_childViewController.view removeFromSuperview];
	
	_parentViewController = parentViewController;
	
	if (_childViewController) {
		[_parentViewController addChildViewController:_childViewController];
		[_childViewController didMoveToParentViewController:_parentViewController];
	}
	
	[self setNeedsLayout];

}

- (void) setChildViewController:(UIViewController *)childViewController {

	if (_childViewController == childViewController)
		return;
	
	[_childViewController willMoveToParentViewController:nil];
	[_childViewController removeFromParentViewController];
	
	if ([_childViewController isViewLoaded]) {
		[_childViewController.view removeFromSuperview];
	}
	
	if ([childViewController.view.superview isKindOfClass:[self class]]) {
		typeof(self) otherCell = (typeof(self))childViewController.view.superview;
		otherCell.childViewController = nil;
		otherCell.parentViewController = nil;
	}
	_childViewController = childViewController;
	
	if (_childViewController) {
		[_parentViewController addChildViewController:_childViewController];
		[_childViewController didMoveToParentViewController:_parentViewController];
	}

	[self setNeedsLayout];

}

- (void) layoutSubviews {

	[super layoutSubviews];

	UIViewController *childVC = self.childViewController;
		
	if (![childVC.view isDescendantOfView:self]) {
		[self addSubview:childVC.view];
	}
	
	childVC.view.frame = self.bounds;

}

- (void) prepareForReuse {
	
	self.parentViewController = nil;
	self.childViewController = nil;

}

@end
