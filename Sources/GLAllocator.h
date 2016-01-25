//
//  GLAllocator.h
//  CeedGL
//
//  Created by Raphael Sebbe on 22/01/15.
//  Copyright (c) 2015 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CeedGL/GLBuffer.h>
#import <CeedGL/GLShader.h>
#import <CeedGL/GLProgram.h>
#import <CeedGL/GLTexture.h>
#import <CeedGL/GLFramebuffer.h>
#import <CeedGL/GLRenderbuffer.h>

/*
 The purpose of GLAllocator is to help allocate and manage GL resources.
 It is not required to use it (CeedGL is fully functional without it), but it can help tracking allocated objects, and releasing them.
 */

@interface GLAllocator : NSObject

@property (copy) NSString *name;	// for debugging, to help identify the allocator

- (NSSet*)allObjects;

// GL context must be set for most methods.
// Create (& allocate) new objects
- (GLTexture*)newTexture:(GLTextureSpecifier)spec;
- (GLBuffer*)newBuffer;
- (GLShader*)newVertexShader;
- (GLShader*)newFragmentShader;
- (GLProgram*)newProgram;
- (GLFramebuffer*)newFramebuffer;
- (GLRenderbuffer*)newRenderbuffer;

// Add pre-allocated objects, allocator takes over allocation manager (will dealloc it)
- (void)addObject:(GLObject*)object;

// Stops managing passed object, you become responsible for deallocating GL resources.
- (void)forgetObject:(GLObject*)object;

// GL context must be set
- (void)destroyObject:(GLObject*)object;
- (void)destroyAllObjects;

@end
