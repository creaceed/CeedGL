//
//  GLTexture+Deprecated2D.m
//  CeedGL
//
//  Created by Raphael Sebbe on 23/01/16.
//  Copyright © 2016 Creaceed. All rights reserved.
//

#import <CeedGL/GLTexture+Deprecated2D.h>
#import "GLTexture+Internal.h"

@implementation GLTexture (Deprecated2D)

- (void)_checkTarget:(GLenum)target {
	GL_EXCEPT(target != self.target, @"Target don't match");
}

- (void)bind:(GLenum)target
{
	GL_EXCEPT(target != self.target, @"Target don't match");
	[self bind];
}

- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat type:(GLenum)type border:(GLint)border target:(GLenum)target
{
	[self setFromExistingHandle:handle width:w height:h internalFormat:iformat type:type border:border target:target owner:nil];
}
- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat type:(GLenum)type border:(GLint)border target:(GLenum)target owner:(id)owner
{
	GLTextureSpecifier spec = GLTextureSpecifierMakeTexture2D(target, w, h, iformat, type);
	spec.border = border;
	
	[self _setSpecifier:spec];
	[self setFromExistingHandle:handle];
	
	self.handleOwner = owner;
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
	GLTextureLoader loader = {0};
	GLTextureSpecifier spec = GLTextureSpecifierMakeTexture2D(target, w, h, iformat, type);
	spec.border = border;
	
	[self _setSpecifier:spec];
	
	loader.mipmapLevel = level;
	
	loader.data.bytes = pixels;
	loader.data.format = format;
	loader.data.type = type;
	
	[self loadImageData:loader];
}

- (void)updateImage:(const GLvoid*)pixels level:(GLint)level xOffset:(GLint)xoff yOffset:(GLint)yoff width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type target:(GLenum)target
{
	[self updateImage:pixels level:level xOffset:xoff yOffset:yoff width:w height:h format:format type:type];
}
- (void)updateImage:(const GLvoid*)pixels level:(GLint)level xOffset:(GLint)xoff yOffset:(GLint)yoff width:(GLsizei)w height:(GLsizei)h format:(GLenum)format type:(GLenum)type
{
	GLTextureUpdater updater = {0};
	
	updater.mipmapLevel = level;
	
	updater.range.x = xoff;
	updater.range.y = yoff;
	updater.range.width = w;
	updater.range.height = h;
	
	updater.data.format = format;
	updater.data.bytes = pixels;
	updater.data.type = type;
	
	[self updateImageData:updater];
}

- (void)setMagFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt target:(GLenum)target
{
	[self _checkTarget:target];
}
- (void)setMagFilter:(GLenum)magfil minFilter:(GLenum)minfil wrapS:(GLenum)wraps wrapT:(GLenum)wrapt
{
	GLTextureParameters params = GLTextureParametersMakeEmpty();
	
	params.filter.mag = magfil;
	params.filter.min = minfil;
	params.filter.mask = GLTextureFilterMaskMagnification | GLTextureFilterMaskMinification;
	
	params.wrapMode.s = wraps;
	params.wrapMode.t = wrapt;
	params.wrapMode.mask = GLTextureWrapModeMaskS | GLTextureWrapModeMaskT;
	
	[self setParameters:params];
}

- (void)copyFramebufferImageToLevel:(GLint)level x:(GLint)x y:(GLint)y width:(GLint)w height:(GLint)h border:(GLint)border internalFormat:(GLenum)iformat type:(GLenum)type target:(GLenum)target
{
	GLTextureLoader loader = {0};
	GLTextureSpecifier spec = GLTextureSpecifierMakeTexture2D(target, w, h, iformat, type);
	
	spec.border = border;
	
	[self _setSpecifier:spec];
	
	loader.source = GLTextureImageSourceFramebuffer;
	loader.mipmapLevel = level;
	
	loader.framebuffer.x = x;
	loader.framebuffer.y = y;
	
	[self loadImageData:loader];
}

@end
