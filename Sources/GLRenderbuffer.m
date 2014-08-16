//
//  GLRenderbuffer.m
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import "GLRenderbuffer.h"


@implementation GLRenderbuffer

@synthesize internalFormat = mInternalFormat, width = mWidth, height = mHeight;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark -
#pragma mark Handle creation/destruction
- (void)createHandle
{
	GL_EXCEPT(mHandle, @"Trying to create a new handle over an existing one");
	
	glGenRenderbuffers(1, &mHandle);
	
	GL_EXCEPT(!mHandle, @"Could not create handle (no current GL context?)"); 
}
- (void)destroyHandle
{
	GL_EXCEPT(mHandle != 0 && mHandleOwner != nil, @"Cannot destroy a handle if lifetime is managed by an owner");
	GL_EXCEPT(!mHandle, @"Trying to destroy a NULL handle");
	
	glDeleteRenderbuffers(1, &mHandle);
	mHandle = 0;
}

#pragma mark -
#pragma mark Storage
- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat
{
	mHandle = handle;
	mWidth = w;
	mHeight = h;
	mInternalFormat = iformat;
}
- (void)allocateStorageWithWidth:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)internalFormat 
{
	if(mHandle == 0)
		[self createHandle];
	
	glBindRenderbuffer(GL_RENDERBUFFER, mHandle);
	glRenderbufferStorage(GL_RENDERBUFFER, internalFormat, w, h);
	glBindRenderbuffer(GL_RENDERBUFFER, 0);
	
	GLCheckError();
	
	mWidth = w;
	mHeight = h;
	mInternalFormat = internalFormat;
}

#pragma mark -
#pragma mark Accessors
- (CGSize)size
{
	return CGSizeMake(mWidth, mHeight);
}

#pragma mark - Binding -
- (void)bind
{
	GL_EXCEPT(mHandle == 0, @"Trying to bind non-existing renderbuffer");
	glBindRenderbuffer(GL_RENDERBUFFER, mHandle);
}
+ (void)unbind
{
	glBindRenderbuffer(GL_RENDERBUFFER, 0);	
}


@end
