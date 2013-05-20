//
//  RADeferredOperation.h
//  RAPageViewController
//
//  Created by Evadne Wu on 12/27/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RADeferredOperation;
typedef void (^RADeferredOperationCompletionBlock)();
typedef void (^RADeferredOperationWorkerBlock)(RADeferredOperation *operation, RADeferredOperationCompletionBlock completionBlock);

@interface RADeferredOperation : NSOperation

- (instancetype) initWithWorkerBlock:(RADeferredOperationWorkerBlock)block;

@end
