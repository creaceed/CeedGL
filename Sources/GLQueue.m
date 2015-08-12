//
//  GLQueue.m
//  CeedGL
//
//  Created by Raphael Sebbe on 11/08/15.
//  Copyright © 2015 Creaceed. All rights reserved.
//

#import <CeedGL/GLQueue.h>
#import <CeedGL/GLAllocator.h>

#if TARGET_OS_IPHONE
#import <OpenGLES/EAGL.h>
#else
#import <AppKit/NSOpenGL.h>
#endif
@interface GLQueue ()

@property (readonly) NSOperationQueue *operationQueue;

@end

@implementation GLQueue
//
//@property (readonly) GLAllocator *allocator;
//@property (readonly) GLQueueState state;

+ (instancetype)queueWithContext:(_GLContext*)context {
	return [[self alloc] initWithContext:context];
}
- (instancetype)initWithContext:(_GLContext*)context
{
	GL_EXCEPT(context == nil, @"Context shouldn't be nil");
	
	self = [super init];
	if(self == nil) return nil;
	
	_context = context;
	_allocator = [[GLAllocator alloc] init];
	_operationQueue = [[NSOperationQueue alloc] init];
	_operationQueue.maxConcurrentOperationCount = 1;
	_state = GLQueueStateRunning;
	
	return self;
}
- (void)dealloc {
	GL_EXCEPT(_state != GLQueueStateTerminated, @"GLQueue must be terminated before it can be deallocated");
}
#if TARGET_OS_IPHONE
- (void)_setCurrentContext { [EAGLContext setCurrentContext:self.context]; }
- (void)_unsetCurrentContext { [EAGLContext setCurrentContext:nil]; }
#else
- (void)_setCurrentContext { [self.context makeCurrentContext]; }
- (void)_unsetCurrentContext { [NSOpenGLContext clearCurrentContext]; }
#endif

// throws an exception if state is not running
- (void)executeBlock:(GLQueueBlock)block wait:(BOOL)wait {
	NSBlockOperation *op;
	@synchronized(_context)
	{
		GL_EXCEPT(_state != GLQueueStateRunning, @"GLQueue is not running");
		block = [block copy];
		void (^b)(void) = ^{
			[self _setCurrentContext];
			block(self);
			[self _unsetCurrentContext];
		};
		op = [NSBlockOperation blockOperationWithBlock:[b copy]];
		[_operationQueue addOperation:op ];
	}
	if(wait)
		[op waitUntilFinished];
}
- (void)executeSyncBlock:(GLQueueBlock)block {
	[self executeBlock:block wait:YES];
}
- (void)executeAsyncBlock:(GLQueueBlock)block {
	[self executeBlock:block wait:NO];
}
- (void)terminate {
	NSOperationQueue *opQueue = _operationQueue;

	@synchronized(_context) {
		GL_EXCEPT(_state != GLQueueStateRunning, @"GLQueue is already terminated");
		_operationQueue = nil;
		_state = GLQueueStateTerminated;
	}
	[opQueue addOperationWithBlock:^{
		[self _setCurrentContext];
		[self.allocator destroyAllObjects];
		[self _unsetCurrentContext];
	}];
	[opQueue waitUntilAllOperationsAreFinished];
	
	_allocator = nil;
	_context = nil;
}
@end
