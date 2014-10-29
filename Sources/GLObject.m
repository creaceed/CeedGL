//
//  GLObject.m
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import "GLObject.h"
#import "GLDebug.h"


@implementation GLObject
@synthesize handle = mHandle;
//@synthesize handleOwner = mHandleOwner;


- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
	self.handleOwner = nil;
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
