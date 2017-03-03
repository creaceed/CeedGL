//
//  GLTexture+GLKit.m
//  CeedGL
//
//  Created by Raphael Sebbe on 28/07/15.
//  Copyright © 2015 Creaceed. All rights reserved.
//
#import <CeedGL/GLTexture+GLKit.h>
#import <GLKit/GLKit.h>

int __linkerFixGLTextureGLKit = 0;

@implementation GLTexture (GLKit)

+ (GLTextureSpecifier)textureSpecifierFromTextureInfo:(GLKTextureInfo*)info {
	GL_EXCEPT(info == nil, NSInvalidArgumentException);
	GL_EXCEPT(info.target == 0, NSInvalidArgumentException);
	GL_EXCEPT(info.width == 0, NSInvalidArgumentException);
	GL_EXCEPT(info.height == 0, NSInvalidArgumentException);
	
	
	GLTextureSpecifier spec = GLTextureSpecifierMakeTexture2D(info.target, info.width, info.height, GL_RGBA, GL_UNSIGNED_BYTE);
	
	return spec;
}

+ (instancetype)textureWithFileAtURL:(NSURL*)url options:(NSDictionary*)options error:(NSError **)perror
{
	GLTexture *texture = nil;
	
	// possibly
	NSError *error;
	GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfURL:url options:nil error:&error];
	
	if(info) {
		GLTextureSpecifier spec = [self textureSpecifierFromTextureInfo:info];

		texture = [GLTexture textureWithSpecifier:spec];
		[texture setFromExistingHandle:info.name];
//		[self setFromExistingHandle:info.name width:info.width height:info.height internalFormat:GL_RGBA type:GL_UNSIGNED_BYTE border:0 target:info.target];
		[texture setMagFilter:GL_LINEAR minFilter:GL_LINEAR];
		[texture setWrapMode:GL_CLAMP_TO_EDGE];
	}
	else {
		if(perror)
			*perror = error;
	}
	return texture;
}

@end
