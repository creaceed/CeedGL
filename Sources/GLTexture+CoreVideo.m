//
//  GLTexture+CoreVideo.m
//  CeedGL
//
//  Created by Raphael Sebbe on 30/07/14.
//  Copyright (c) 2014 Creaceed. All rights reserved.
//

#import <CeedGL/GLTexture+CoreVideo.h>
#import <OpenGLES/ES2/glext.h>

// Linker is issuing warning because there is no symbol in this static lib (just a category)
// Defining this global variable solves that issue.
NSString * const _CeedGLCoreVideoExt_linkerWarningWorkaround = nil;

static GLenum _glFormatForPixelFormat(OSType type, size_t planei)
{
	switch (type) {
		// Non-planar
		case kCVPixelFormatType_32BGRA:
		case kCVPixelFormatType_32RGBA:
		case kCVPixelFormatType_32ABGR:
		case kCVPixelFormatType_32ARGB:
			return GL_RGBA;
			
		case kCVPixelFormatType_OneComponent8:
		case kCVPixelFormatType_OneComponent16Half:
			return GL_RED_EXT;
			
		// Planar
		case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
		case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
			return planei==0?GL_RED_EXT:GL_RG_EXT;
	}
	GL_ASSERT(0);
	GL_EXCEPT(1, @"Unsupported case");
	
	return GL_RGBA;
}

static GLenum _glTypeForPixelFormat(OSType type, size_t planei)
{
	switch (type) {
			// Non-planar
		case kCVPixelFormatType_32BGRA:
		case kCVPixelFormatType_32RGBA:
		case kCVPixelFormatType_32ABGR:
		case kCVPixelFormatType_32ARGB:
		case kCVPixelFormatType_OneComponent8:
		case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
		case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
			return GL_UNSIGNED_BYTE;
			
		case kCVPixelFormatType_OneComponent16Half:
#if TARGET_OS_IPHONE
			return GL_HALF_FLOAT_OES;
#else
			return GL_HALF_FLOAT; // Not tested
#endif
	}
	
	GL_ASSERT(0);
	GL_EXCEPT(1, @"Unsupported case");
	
	return GL_UNSIGNED_BYTE;
}


@implementation GLTexture (CoreVideo)

//+ (OSType)

+ (CVOpenGLESTextureRef)_createTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer inTextureCache:(CVOpenGLESTextureCacheRef)textureCache plane:(GLVideoPlane)plane outputSize:(CGSize*)osize
{
	BOOL planar = CVPixelBufferIsPlanar(pixelBuffer);
	size_t planei = (plane==GLVideoPlaneChroma?1:0);
	OSType pixformat = CVPixelBufferGetPixelFormatType(pixelBuffer);
	GLenum format = _glFormatForPixelFormat(pixformat, planei);
	GLenum gltype = _glTypeForPixelFormat(pixformat, planei);
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

+ (GLTexture*)_textureFromCVT:(CVOpenGLESTextureRef)inputCVT format:(GLenum)format type:(GLenum)type size:(CGSize)cvtSize  outTarget:(GLenum*)otarget
{
	GLTexture *texture = [GLTexture texture];
	//CGSize cvtSize = CVImageBufferGetDisplaySize(inputCVT);
	
	[texture setFromExistingHandle:CVOpenGLESTextureGetName(inputCVT) width:cvtSize.width height:cvtSize.height internalFormat:format type:type border:0 owner:(__bridge id)inputCVT];
	
	GLenum target = CVOpenGLESTextureGetTarget(inputCVT);
	
	if(otarget) *otarget = target;
	
//	[texture bind:target];
//	glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//	glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//	glTexParameterf(target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//	glTexParameterf(target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	return texture;
}
+ (GLTexture*)textureFromPixelBuffer:(CVPixelBufferRef)pixelBuffer inTextureCache:(CVOpenGLESTextureCacheRef)textureCache plane:(GLVideoPlane)plane outTarget:(GLenum*)otarget
{
	GLenum target;
	CGSize size;
	OSType pixformat = CVPixelBufferGetPixelFormatType(pixelBuffer);
	size_t planei = (plane==GLVideoPlaneChroma?1:0);
	CVOpenGLESTextureRef CVT = [self _createTextureForPixelBuffer:pixelBuffer inTextureCache:textureCache plane:plane outputSize:&size]; GL_ASSERT(CVT);
	GLTexture *texture = [self _textureFromCVT:CVT format:_glFormatForPixelFormat(pixformat, planei) type:_glTypeForPixelFormat(pixformat, planei) size:size outTarget:&target];
	
	// CVT is now owned by texture
	CFRelease(CVT);
	
	if(otarget) *otarget = target;
	
	return texture;
}

@end
