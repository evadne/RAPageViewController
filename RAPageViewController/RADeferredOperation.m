//
//  RADeferredOperation.m
//  RAPageViewController
//
//  Created by Evadne Wu on 12/27/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RADeferredOperation.h"

@interface RADeferredOperation ()
@property (nonatomic, readonly, copy) RADeferredOperationWorkerBlock workerBlock;
@property (nonatomic, readonly, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, readonly, assign, getter=isFinished) BOOL finished;
@end

@implementation RADeferredOperation
@synthesize workerBlock = _workerBlock;
@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype) initWithWorkerBlock:(RADeferredOperationWorkerBlock)block {

	self = [super init];
	if (!self)
		return nil;
	
	_workerBlock = [block copy];
	
	return self;

}

- (void) start {

	if ([self isCancelled]) {
		self.finished = YES;
		return;
	}
	
	self.executing = YES;
	dispatch_async(dispatch_get_main_queue(), ^{
	
		self.workerBlock(self, ^ {
			
			NSCParameterAssert([NSThread isMainThread]);
			
			if ([self isCancelled])
				return;
			
			self.executing = NO;
			self.finished = YES;
	
		});
		
	});
	
}

- (void) cancel {

	[super cancel];

	if (self.executing)
		self.finished = YES;
	
	self.executing = NO;
	
}

- (BOOL) isConcurrent {

	return YES;

}

- (void) setFinished:(BOOL)finished {

	if (_finished == finished)
		return;
	
	[self willChangeValueForKey:@"isFinished"];
	[self willChangeValueForKey:@"progress"];
	
	_finished = finished;
	
	[self didChangeValueForKey:@"progress"];
	[self didChangeValueForKey:@"isFinished"];

}

- (void) setExecuting:(BOOL)executing {

	if (_executing == executing)
		return;
	
	[self willChangeValueForKey:@"isExecuting"];
	_executing = executing;
	[self didChangeValueForKey:@"isExecuting"];

}

@end
