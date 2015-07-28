//
//  GLTexture+GLKit.m
//  CeedGL
//
//  Created by Raphael Sebbe on 28/07/15.
//  Copyright © 2015 Creaceed. All rights reserved.
//
#import <CeedGL/GLTexture+GLKit.h>
#import <GLKit/GLKit.h>

@implementation GLTexture (GLKit)

- (BOOL)loadFromFileAtURL:(NSURL*)url options:(NSDictionary*)options error:(NSError **)perror
{
	BOOL res;
	GL_EXCEPT(self.handle != 0, NSInvalidArgumentException);
	
	// possibly
	NSError *error;
	GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfURL:url options:nil error:&error];
	
	if(info) {
		[self setFromExistingHandle:info.name width:info.width height:info.height internalFormat:GL_RGBA type:GL_UNSIGNED_BYTE border:0];
		[self setMagFilter:GL_LINEAR minFilter:GL_LINEAR wrapS:GL_CLAMP_TO_EDGE wrapT:GL_CLAMP_TO_EDGE target:GL_TEXTURE_2D];
		res = YES;
	}
	else {
		if(perror)
			*perror = error;
		res = NO;
	}
	return res;
}

@end
