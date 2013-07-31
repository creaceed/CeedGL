//
//  GLRenderbuffer.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLObject.h"
#import <QuartzCore/QuartzCore.h>

@interface GLRenderbuffer : GLObject {
	
	GLenum 			mInternalFormat;
	GLsizei 		mWidth, mHeight;
}

@property (readonly, nonatomic)	GLenum 		internalFormat;
@property (readonly, nonatomic)	GLsizei 	width, height;
@property (readonly, nonatomic) CGSize 		size; // same as width/height

- (void)setFromExistingHandle:(GLuint)handle width:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)iformat;
- (void)allocateStorageWithWidth:(GLsizei)w height:(GLsizei)h internalFormat:(GLenum)internalFormat ;

@end
