//
//  GLTexture+Deprecated2D.h
//  CeedGL
//
//  Created by Raphael Sebbe on 23/01/16.
//  Copyright © 2016 Creaceed. All rights reserved.
//

#import <CeedGL/GLTexture.h>

@interface GLTexture (Deprecated2D)

//		2D
- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat type:(GLenum)type border:(GLint)border target:(GLenum)target  GL_DEPRECATED_MSG("Use setFromExistingHandle instead");

// Create on GPU with no contents
// 		2D
- (void)allocateStorageWithWidth:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type internalFormat:(GLenum)iformat target:(GLenum)target GL_DEPRECATED_MSG("Use allocateStorage instead");

// Create on GPU and load contents
// 		2D
- (void)loadImage:(const GLvoid *)pixels width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type internalFormat:(GLenum)iformat target:(GLenum)target GL_DEPRECATED_MSG("Use loadImageData instead");

// Update part of the texture. pixels is a pointer to the first pixel of the new data.
// 		2D
- (void)updateImage:(const GLvoid*)pixels level:(GLint)level xOffset:(GLint)xoff yOffset:(GLint)yoff width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type GL_DEPRECATED_MSG("Use updateImageData instead");
- (void)setMagFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt GL_DEPRECATED_MSG("Use setParameter instead");

// Deprecated methods
- (void)updateImage:(const GLvoid*)pixels level:(GLint)level xOffset:(GLint)xoff yOffset:(GLint)yoff width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type target:(GLenum)target GL_DEPRECATED_MSG("Target is now part of GLTexture, use method with no target argument instead");
- (void)setMagFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt target:(GLenum)target GL_DEPRECATED_MSG("Target is now part of GLTexture, use method with no target argument instead");
- (void)copyFramebufferImageToLevel:(GLint)level x:(GLint)x y:(GLint)y width:(GLint)w height:(GLint)height border:(GLint)border internalFormat:(GLenum)iformat type:(GLenum)type target:(GLenum)target GL_DEPRECATED_MSG("Target is now part of GLTexture, use method with no target argument instead");
- (void)bind:(GLenum)target GL_DEPRECATED_MSG("Target is now part of GLTexture, use method with no target argument instead");
- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat type:(GLenum)type border:(GLint)border target:(GLenum)target owner:(id)owner GL_DEPRECATED_MSG("owner parameter must now be set separately");
- (void)loadImage:(const GLvoid*)pixels level:(GLint)level width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type border:(GLint)border internalFormat:(GLenum)iformat target:(GLenum)target magFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt GL_DEPRECATED_MSG("Set min / mag / wrap modes through separate calls");

@end
