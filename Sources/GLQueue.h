//
//  GLQueue.h
//  CeedGL
//
//  Created by Raphael Sebbe on 11/08/15.
//  Copyright © 2015 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, GLQueueState) {
	GLQueueStateRunning,
	GLQueueStateTerminated
};

#if TARGET_OS_IPHONE
#define _GLContext EAGLContext
#else 
#define _GLContext NSOpenGLContext
#endif


@class GLQueue, NSOpenGLContext, EAGLContext, GLAllocator;

typedef void(^GLQueueBlock)(GLQueue *queue);

@interface GLQueue : NSObject

@property (readonly) GLAllocator *allocator;
@property (readonly) GLQueueState state;
@property (readonly) _GLContext *context;

+ (instancetype)queueWithContext:(_GLContext*)context;

// Execute a block with GL context set. Throws an exception if state is not running
- (void)executeBlock:(GLQueueBlock)block wait:(BOOL)wait;
- (void)executeSyncBlock:(GLQueueBlock)block;
- (void)executeAsyncBlock:(GLQueueBlock)block;

// cleans up all allocated GL object and destroys internal queue
- (void)terminate;


@end
