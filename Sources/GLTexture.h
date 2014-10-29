//
//  GLTexture.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLObject.h"
#import <QuartzCore/QuartzCore.h>


@interface GLTexture : GLObject {
	GLsizei 	mWidth, mHeight;
	GLenum		mInternalFormat;				// ex. GL_RGBA
	GLenum 		mType;						// ex. GL_UNSIGNED_BYTE
	GLint		mBorder;
}

@property (readonly, nonatomic) GLsizei 	width, height;
@property (readonly, nonatomic) CGSize 		size; // same as width/height
@property (readonly, nonatomic) GLenum 		internalFormat, type;
@property (readonly, nonatomic) GLint 		border;


// GLTexture creation
+ (GLTexture*)texture;

// Texture definition
- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat type:(GLenum)type border:(GLint)border;
- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat type:(GLenum)type border:(GLint)border owner:(id)owner;

// Create on GPU with no contents
- (void)allocateStorageWithWidth:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type internalFormat:(GLenum)iformat target:(GLenum)target;

// Create on GPU and load contents
- (void)loadImage:(const GLvoid *)pixels width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type internalFormat:(GLenum)iformat target:(GLenum)target;
- (void)loadImage:(const GLvoid*)pixels level:(GLint)level width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type border:(GLint)border internalFormat:(GLenum)iformat target:(GLenum)target magFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt;

// Update part of the texture. pixels is a pointer to the first pixel of the new data.
- (void)updateImage:(const GLvoid*)pixels level:(GLint)level xOffset:(GLint)xoff yOffset:(GLint)yoff width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type target:(GLenum)target;

- (void)setMagFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt target:(GLenum)target;

- (void)copyFramebufferImageToLevel:(GLint)level x:(GLint)x y:(GLint)y width:(GLint)w height:(GLint)height border:(GLint)border internalFormat:(GLenum)iformat target:(GLenum)target;

// Binding
- (void)bind:(GLenum)target;
+ (void)unbind:(GLenum)target;

@end
