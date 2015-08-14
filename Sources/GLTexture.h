//
//  GLTexture.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CeedGL/GLObject.h>

@interface GLTexture : GLObject {
	GLsizei 	mWidth, mHeight;
	GLenum		mInternalFormat;			// ex. GL_RGBA
	GLenum 		mType;						// ex. GL_UNSIGNED_BYTE
	GLint		mBorder;
	GLenum		mTarget;					// 0 initially until it has been determined (setFromExisting / allocated / loaded / etc.).
}

@property (readonly, nonatomic) GLsizei 	width, height;
@property (readonly, nonatomic) CGSize 		size; // same as width/height
@property (readonly, nonatomic) GLenum 		internalFormat, type;
@property (readonly, nonatomic) GLint 		border;

// Note about target: now storing it as part of the GLTexture object. The rationale is that, unlike buffer objects which can be bound to different targets,
// texture object can change target after it has been determined. So instead of maintaining it outside of GLTexture, we now store it here directly.
// its value is 0 initially (undetermined) until it has been determined by specific methods below. setFromExisting / allocated / loaded / etc.).
// Because of this change, some methods are deprecated, and some other are replaced. In the deprecated methods, a target mismatch triggers an exception.
@property (readonly, nonatomic) GLenum 		target;


// GLTexture creation
+ (instancetype)texture;

// Texture definition
- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat type:(GLenum)type border:(GLint)border target:(GLenum)target;
- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat type:(GLenum)type border:(GLint)border target:(GLenum)target owner:(id)owner;

// Create on GPU with no contents
- (void)allocateStorageWithWidth:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type internalFormat:(GLenum)iformat target:(GLenum)target;

// Create on GPU and load contents
- (void)loadImage:(const GLvoid *)pixels width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type internalFormat:(GLenum)iformat target:(GLenum)target;
- (void)loadImage:(const GLvoid*)pixels level:(GLint)level width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type border:(GLint)border internalFormat:(GLenum)iformat target:(GLenum)target magFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt;

// Update part of the texture. pixels is a pointer to the first pixel of the new data.
- (void)updateImage:(const GLvoid*)pixels level:(GLint)level xOffset:(GLint)xoff yOffset:(GLint)yoff width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type;
- (void)setMagFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt;
- (void)copyFramebufferImageToLevel:(GLint)level x:(GLint)x y:(GLint)y width:(GLint)w height:(GLint)height border:(GLint)border internalFormat:(GLenum)iformat;

// Binding
- (void)bind;
- (void)unbind;
+ (void)unbind:(GLenum)target;


// Deprecated methods
- (void)updateImage:(const GLvoid*)pixels level:(GLint)level xOffset:(GLint)xoff yOffset:(GLint)yoff width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type target:(GLenum)target GL_DEPRECATED_MSG("Target is now part of GLTexture, use method with no target argument instead");
- (void)setMagFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt target:(GLenum)target GL_DEPRECATED_MSG("Target is now part of GLTexture, use method with no target argument instead");
- (void)copyFramebufferImageToLevel:(GLint)level x:(GLint)x y:(GLint)y width:(GLint)w height:(GLint)height border:(GLint)border internalFormat:(GLenum)iformat target:(GLenum)target GL_DEPRECATED_MSG("Target is now part of GLTexture, use method with no target argument instead");
- (void)bind:(GLenum)target GL_DEPRECATED_MSG("Target is now part of GLTexture, use method with no target argument instead");


@end
