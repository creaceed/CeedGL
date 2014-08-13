//
//  GLTexture+CoreVideo.m
//  CeedGL
//
//  Created by Raphael Sebbe on 30/07/14.
//  Copyright (c) 2014 Creaceed. All rights reserved.
//

#import "GLTexture+CoreVideo.h"
#import <OpenGLES/ES2/glext.h>

// Linker is issuing warning because there is no symbol in this static lib (just a category)
// Defining this global variable solves that issue.
NSString * const _CeedGLCoreVideoExt_linkerWarningWorkaround = nil;

static GLenum _glFormatForTextureType(GLVideoTextureType type)
{
	switch (type) {
		// Non-planar
		case GLVideoTextureTypeRGBA: return GL_RGBA;
		case GLVideoTextureTypeR: return GL_RED_EXT;
		case GLVideoTextureTypeR16h: return GL_RED_EXT;
			
		// Planar
		case GLVideoTextureTypeLuma: return GL_RED_EXT;
		case GLVideoTextureTypeChroma: return GL_RG_EXT;
	}
	GL_ASSERT(0);
}

static GLenum _glTypeForTextureType(GLVideoTextureType type)
{
	switch (type) {
		// Non-planar
		case GLVideoTextureTypeRGBA: return GL_UNSIGNED_BYTE;
		case GLVideoTextureTypeR: return GL_UNSIGNED_BYTE;
#if TARGET_OS_IPHONE
		case GLVideoTextureTypeR16h: return GL_HALF_FLOAT_OES;
#else
		case GLVideoTextureTypeR16h: return GL_HALF_FLOAT; // Not tested
#endif
		// Planar
		case GLVideoTextureTypeLuma: return GL_UNSIGNED_BYTE;
		case GLVideoTextureTypeChroma: return GL_UNSIGNED_BYTE;
	}
	
	GL_ASSERT(0);
}


@implementation GLTexture (CoreVideo)

+ (CVOpenGLESTextureRef)_createTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer inTextureCache:(CVOpenGLESTextureCacheRef)textureCache type:(GLVideoTextureType)type outputSize:(CGSize*)osize
{
	BOOL planar = (type >= GLVideoTextureTypeLuma);
	size_t planei = (type==GLVideoTextureTypeChroma?1:0);
	GLenum format = _glFormatForTextureType(type);
	GLenum gltype = _glTypeForTextureType(type);
	int w,h;
	
	if(planar) {
		w = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer, planei);
		h = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer, planei);
	}
	else {
		w = (int)CVPixelBufferGetWidth(pixelBuffer);
		h = (int)CVPixelBufferGetHeight(pixelBuffer);
	}
	CVOpenGLESTextureRef texture = NULL;
	CVReturn err;
	
	if (!textureCache) {
		GLLogWarning(@"No video texture cache");
		return NULL;
	}
	
	// CVOpenGLTextureCacheCreateTextureFromImage will create GL texture optimally from CVPixelBufferRef.
	// Y
	err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
													   textureCache,
													   pixelBuffer,
													   NULL,
													   GL_TEXTURE_2D,
													   format,
													   w,
													   h,
													   format,
													   gltype,
													   planei,
													   &texture);
	
	if(osize) {
		*osize = CGSizeMake(w, h);
	}
	
	if (!texture || err) {
		GLLogWarning(@"Error at creating texture using CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
	}
	return texture;
	
}

+ (GLTexture*)_textureFromCVT:(CVOpenGLESTextureRef)inputCVT format:(GLenum)format size:(CGSize)cvtSize  outTarget:(GLenum*)otarget
{
	GLTexture *texture = [GLTexture texture];
	//CGSize cvtSize = CVImageBufferGetDisplaySize(inputCVT);
	
	[texture setFromExistingHandle:CVOpenGLESTextureGetName(inputCVT) width:cvtSize.width height:cvtSize.height internalFormat:format border:0 owner:(__bridge id)inputCVT];
	
	GLenum target = CVOpenGLESTextureGetTarget(inputCVT);
	
	if(otarget) *otarget = target;
	
//	[texture bind:target];
//	glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//	glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//	glTexParameterf(target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//	glTexParameterf(target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	return texture;
}
+ (GLTexture*)textureFromPixelBuffer:(CVPixelBufferRef)pixelBuffer inTextureCache:(CVOpenGLESTextureCacheRef)textureCache type:(GLVideoTextureType)type outTarget:(GLenum*)otarget
{
	GLenum target;
	CGSize size;
	CVOpenGLESTextureRef CVT = [self _createTextureForPixelBuffer:pixelBuffer inTextureCache:textureCache type:(GLVideoTextureType)type outputSize:&size]; GL_ASSERT(CVT);
	GLTexture *texture = [self _textureFromCVT:CVT format:_glFormatForTextureType(type) size:size outTarget:&target];
	
	// CVT is now owned by texture
	CFRelease(CVT);
	
	if(otarget) *otarget = target;
	
	return texture;
}

@end
