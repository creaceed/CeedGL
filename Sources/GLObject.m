//
//  GLObject.m
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import "GLObject.h"


@implementation GLObject
@synthesize handle = mHandle;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
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

@end
