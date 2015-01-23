//
//  GLShader.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CeedGL/GLObject.h>

#define GL_STRINGIFY(A) [NSString stringWithCString:#A encoding:NSUTF8StringEncoding]

@interface GLShader : GLObject {
    GLenum 		mType;
	NSString	*mSource;
}

@property (readonly, nonatomic) GLenum 		type;
//@property (readwrite, nonatomic, strong) NSString 	*source;

- (instancetype)initWithType:(GLenum)type;
- (instancetype)initVertexShader;
- (instancetype)initFragmentShader;

+ (instancetype)vertexShader;
+ (instancetype)fragmentShader;

- (void)setSource:(NSString*)source;
- (BOOL)compile:(NSError**)error;


@end
