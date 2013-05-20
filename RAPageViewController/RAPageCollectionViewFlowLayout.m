//
//  RAPageCollectionViewFlowLayout.m
//  RAPageViewController
//
//  Created by Evadne Wu on 12/25/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RAPageCollectionViewFlowLayout.h"

@implementation RAPageCollectionViewFlowLayout

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	
	return YES;

}

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {

	NSArray *answer = [super layoutAttributesForElementsInRect:rect];
	
	//	The header / footer which is visible but off-screen-bounds
	//	is added to preserve appearance of an even page spacing
	//	and therefore superfluous, we can remove them
	
	//	I chose to implement page spacing using headers and footers
	//	simply because so the content inset is left
	//	for the end users and other calling sites to mutate
	
	//	It is understood that everything contained by the collection
	//	view is private, but people should feel free to re-configure
	//	everything.
	
	return [answer filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(UICollectionViewLayoutAttributes *attributes, NSDictionary *bindings) {
		
		return (BOOL)(attributes.representedElementCategory == UICollectionElementCategoryCell);
		
	}]];
	
	return answer;

}

- (CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {

	if (CGPointEqualToPoint(CGPointZero, velocity))
		return proposedContentOffset;
	
	switch (self.scrollDirection) {
		
		case UICollectionViewScrollDirectionHorizontal: {
		
			CGFloat pageWidth = (self.minimumLineSpacing + self.itemSize.width);
			
			return (CGPoint){
				roundf(proposedContentOffset.x / pageWidth) * pageWidth,
				proposedContentOffset.y
			};
		
		}
		
		case UICollectionViewScrollDirectionVertical: {
		
			CGFloat pageHeight = (self.minimumLineSpacing + self.itemSize.height);
			
			return (CGPoint){
				proposedContentOffset.x,
				roundf(proposedContentOffset.y / pageHeight) * pageHeight
			};
		
		}
	
	}

}

@end
