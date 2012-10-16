//
//  GLTexture.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CeedGL/GLObject.h>

@interface GLTexture : GLObject {
	GLsizei 	mWidth, mHeight;
	GLenum		mInternalFormat;				// ex. GL_RGBA
	//GLenum 		mType;						// ex. GL_UNSIGNED_BYTE
	GLint		mBorder;
}

@property (readonly, nonatomic) GLsizei 	width, height;
@property (readonly, nonatomic) CGSize 		size; // same as width/height
@property (readonly, nonatomic) GLenum 		internalFormat;//, type;
@property (readonly, nonatomic) GLint 		border;


// GLTexture creation
+ (GLTexture*)texture;

// Texture definition
- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat border:(GLint)border;

// Create on GPU with no contents
- (void)allocateStorageWithWidth:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type internalFormat:(GLenum)iformat target:(GLenum)target;

// Create on GPU and load contents
- (void)loadImage:(const GLvoid *)pixels width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type internalFormat:(GLenum)iformat target:(GLenum)target;
- (void)loadImage:(const GLvoid*)pixels level:(GLint)level width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type border:(GLint)border internalFormat:(GLenum)iformat target:(GLenum)target magFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt;

- (void)copyFramebufferImageToLevel:(GLint)level x:(GLint)x y:(GLint)y width:(GLint)w height:(GLint)height border:(GLint)border internalFormat:(GLenum)iformat target:(GLenum)target;

// Binding
- (void)bind:(GLenum)target;

@end
