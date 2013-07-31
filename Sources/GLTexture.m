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

- (void)allocateStorageWithWidth:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type internalFormat:(GLenum)iformat target:(GLenum)target
{
	[self loadImage:NULL width:w height:h format:format type:type internalFormat:iformat target:target];
}
- (void)loadImage:(const GLvoid *)pixels width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type internalFormat:(GLenum)iformat target:(GLenum)target
{
	[self loadImage:pixels level:0 width:w height:h format:format type:type border:0 internalFormat:iformat target:target magFilter:GL_NEAREST minFilter:GL_NEAREST wrapS:GL_CLAMP_TO_EDGE wrapT:GL_CLAMP_TO_EDGE];
}

- (void)loadImage:(const GLvoid*)pixels level:(GLint)level width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type border:(GLint)border internalFormat:(GLenum)iformat target:(GLenum)target magFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt
{
	BOOL npot = ((w & (w - 1)) != 0) || ((h & (h - 1)) != 0);
	
	if(mHandle == 0) 
		[self createHandle];
	
	glBindTexture(target, mHandle);
		
	if(npot)
	{
		// NPOT textures always need this, or may otherwise be incomplete
		// And thus we set it here.
		wraps = GL_CLAMP_TO_EDGE;
		wrapt = GL_CLAMP_TO_EDGE;
	}
	
//	int align = 1;
//	glPixelStorei(GL_UNPACK_ALIGNMENT, align);
	glTexParameteri(target, GL_TEXTURE_WRAP_S, wraps);
	glTexParameteri(target, GL_TEXTURE_WRAP_T, wrapt);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	GLCheckError();
	
	glTexImage2D(target, level, iformat, w, h, border, format, type, pixels);
	GLCheckError();
	
	mWidth = w;
	mHeight = h;
	mInternalFormat = iformat;
	//mType = type;
	mBorder = border;
}

- (void)updateImage:(const GLvoid*)pixels level:(GLint)level xOffset:(GLint)xoff yOffset:(GLint)yoff width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type target:(GLenum)target
{
	GL_EXCEPT(mHandle == 0, @"Trying to update non-existing buffer");
	
	glBindTexture(target, mHandle);
	GLCheckError();
	
	glTexSubImage2D(target, level, xoff, yoff, w, h, format, type, pixels);
	GLCheckError();
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
	
	// should not be passed in modern profile OpenGL. Only for fixed-function pipeline, which we don't handle.
	// glEnable(GL_TEXTURE_2D);
	glBindTexture(target, mHandle);
	GLCheckError();
}
+ (void)unbind:(GLenum)target
{
	glBindTexture(target, 0);
}

#pragma mark -
#pragma mark Accessors
- (CGSize)size
{
	return CGSizeMake(mWidth, mHeight);
}
@end
