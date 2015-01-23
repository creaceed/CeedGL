//
//  GLObject.m
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <CeedGL/GLObject.h>
#import "GLObject+Internal.h"


@implementation GLObject
@synthesize handle = mHandle;
//@synthesize handleOwner = mHandleOwner;


- (instancetype)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
	if(mHandle && mHandleOwner == nil)
	{
		GLLog(@"warning: %@ handle not destroyed (%d)", NSStringFromClass(self.class), (int)mHandle);
	}
	
	self.handleOwner = nil;
}

- (NSString *)_ownerDescription {
	if(mHandleOwner && [mHandleOwner isKindOfClass:GLAllocatorReference.class]) {
		GLAllocator *allocator = ((GLAllocatorReference*)mHandleOwner).allocator;
		return [allocator description];
	}
	
	return [mHandleOwner description];
}

- (void)createHandle
{
	GL_EXCEPT(1, @"Abstract method, should be overridden");
}
- (void)forgetHandle
{
	mHandle = 0;
}
- (void)destroyHandle
{
	GL_EXCEPT(1, @"Abstract method, should be overridden");	
}

- (void)setHandleOwner:(id)handleOwner
{
	if(handleOwner != mHandleOwner)
	{
		mHandleOwner = handleOwner;
	}
}
- (id)handleOwner {
	// no retain autorelease, don't extend lifetime of owner
	return mHandleOwner;
}
@end

@implementation GLAllocatorReference
@end