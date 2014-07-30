//
//  GLObject.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CeedGL/GLPlatform.h>

// Handle based OpenGL object

@interface GLObject : NSObject {
@protected
	GLuint 		mHandle;
	id 			mHandleOwner;
}

@property (readonly, nonatomic) GLuint handle;

// if handle lifetime is managed by another object (like CVOpenGLESTextureRef), set it here. That object is released when GLObject is deallocated.
@property (retain) id handleOwner;

// Handle creation/destruction
- (void)createHandle;
- (void)forgetHandle;
- (void)destroyHandle;

@end
