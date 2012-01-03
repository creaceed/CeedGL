//
//  GLTexture.m
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import "GLTexture.h"


@implementation GLTexture

@synthesize width = mWidth, height = mHeight, internalFormat = mInternalFormat,  border = mBorder; // type = mType,

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
+ (GLTexture*)texture
{
	return [[[self alloc] init] autorelease];
}


- (void)createHandle
{
	GL_EXCEPT(mHandle, @"Trying to create a new handle over an existing one");
	
	glGenTextures(1, &mHandle);
	
	GL_EXCEPT(!mHandle, @"Could not create handle (no current GL context?)"); 
}

- (void)destroyHandle
{
	GL_EXCEPT(!mHandle, @"Trying to destroy a NULL handle");
	
	glDeleteTextures(1, &mHandle);
	mHandle = 0;
}

- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat border:(GLint)border
{
	if(handle != mHandle)
	{
		mHandle = handle;
		mWidth = w;
		mHeight = h;
		mInternalFormat = iformat;
		mBorder = border;
	}
}
- (void)loadImage:(const GLvoid*)pixels level:(GLint)level width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type border:(GLint)border internalFormat:(GLenum)iformat target:(GLenum)target
{
	if(mHandle == 0) 
		[self createHandle];
	
	glBindTexture(target, mHandle);
	glTexImage2D(target, level, iformat, w, h, border, format, type, pixels);
	glBindTexture(target, 0);
	
	mWidth = w;
	mHeight = h;
	mInternalFormat = iformat;
	//mType = type;
	mBorder = border;
}

- (void)copyFramebufferImageToLevel:(GLint)level x:(GLint)x y:(GLint)y width:(GLint)w height:(GLint)h border:(GLint)border internalFormat:(GLenum)iformat target:(GLenum)target
{
	if(mHandle == 0) 
		[self createHandle];
	
	glBindTexture(target, mHandle);
	glCopyTexImage2D(target, level, iformat, x, y, w, h, border);
	glBindTexture(target, 0);
	
	mWidth = w;
	mHeight = h;
	mInternalFormat = iformat;
	mBorder = border;
}
- (void)bind:(GLenum)target
{
	GL_EXCEPT(mHandle == 0, @"Trying to bind non-existing buffer");
	
	glBindTexture(target, mHandle);
}
@end
