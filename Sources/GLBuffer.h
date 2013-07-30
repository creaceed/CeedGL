//
//  GLBuffer.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLObject.h"
#import "GLBufferDataSource.h"

@interface GLBuffer : GLObject {
	GLenum 		mUsage;
	GLsizeiptr 	mSize;
}

@property (readonly, nonatomic) GLenum 		usage;
@property (readonly, nonatomic) GLsizeiptr 	size;

+ (GLBuffer*)buffer;

// Loading data 
- (void)setFromExistingHandle:(GLuint)handle size:(GLsizeiptr)size usage:(GLenum)usage;
- (void)loadData:(const GLvoid*)data size:(GLsizeiptr)size usage:(GLenum)usage target:(GLenum)target;
- (void)loadSubData:(const GLvoid*)data offset:(GLintptr)offset size:(GLsizeiptr)size target:(GLenum)target;

// Loading data from data source
- (void)loadDataFromSource:(id<GLBufferDataSource>)source usage:(GLenum)usage target:(GLenum)target;
- (void)loadSubDataFromSource:(id<GLBufferDataSource>)source offset:(GLintptr)offset size:(GLsizeiptr)size target:(GLenum)target;

// Binding
- (void)bind:(GLenum)target;

@end
