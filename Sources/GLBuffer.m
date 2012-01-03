//
//  GLBuffer.m
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import "GLBuffer.h"


@implementation GLBuffer

@synthesize usage = mUsage, size = mSize;

+ (GLBuffer*)buffer
{
	return [[[self alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
	if(mHandle)
	{
		GLLog(@"warning: handle not destroyed");
	}
	
    [super dealloc];
}

#pragma mark -
#pragma mark Handle creation/destruction
- (void)createHandle
{
	GL_EXCEPT(mHandle, @"Trying to create a new handle over an existing one");
	
	glGenBuffers(1, &mHandle);
	
	GL_EXCEPT(!mHandle, @"Could not create handle (no current GL context?)"); 
}
- (void)destroyHandle
{
	GL_EXCEPT(!mHandle, @"Trying to destroy a NULL handle");
	
	glDeleteBuffers(1, &mHandle);
	mHandle = 0;
}
- (void)setFromExistingHandle:(GLuint)handle size:(GLsizeiptr)size usage:(GLenum)usage
{
	mHandle = handle;
	mSize = size;
	mUsage = usage;
}
- (void)loadData:(const GLvoid*)data size:(GLsizeiptr)size usage:(GLenum)usage target:(GLenum)target
{
	if(mHandle == 0) 
		[self createHandle];
		
	glBindBuffer(target, mHandle);
	glBufferData(target, size, data, usage);
	glBindBuffer(target, 0);
	
	mSize = size;
	mUsage = usage;
}
- (void)loadSubData:(const GLvoid*)data offset:(GLintptr)offset size:(GLsizeiptr)size target:(GLenum)target
{
	GL_EXCEPT(mHandle == 0, @"Trying to load subdata on non-existing buffer");
	glBindBuffer(target, mHandle);
	glBufferSubData(target, offset, size, data);
	glBindBuffer(target, 0);
}
- (void)loadDataFromSource:(id<GLBufferDataSource>)source usage:(GLenum)usage target:(GLenum)target
{
	[self loadData:[source bufferData] size:[source bufferDataSize] usage:usage target:target];
}
- (void)loadSubDataFromSource:(id<GLBufferDataSource>)source offset:(GLintptr)offset size:(GLsizeiptr)size target:(GLenum)target
{
	[self loadSubData:[source bufferData]+offset offset:offset size:size target:target];
}

- (void)bind:(GLenum)target
{
	GL_EXCEPT(mHandle == 0, @"Trying to bind non-existing buffer");
	glBindBuffer(target, mHandle);
}

@end
