//
//  GLValue.h
//  CeedGL
//
//  Created by Raphael Sebbe on 06/11/10.
//  Copyright 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPlatform.h"

@interface GLValue : NSObject {
	GLsizei 	mSize; 			// 1, 2, 3, or 4;
	GLsizei		mCount;			// 1 for non-array, >= 1 for arrays
	GLenum		mType; 			// GL_FLOAT or GL_INT
	GLfloat 	mValues[16];
	NSData 		*mValuesArrayData;
	
	BOOL		mIsMatrix;
	BOOL		mIsArray;
}

@property (readonly, nonatomic) 	GLint 				size;
@property (readonly, nonatomic) 	BOOL 				isMatrix, isVector;
@property (readonly, nonatomic) 	BOOL 				isArray;
@property (readonly, nonatomic)		const GLfloat 		*floatValues;
@property (readonly, nonatomic)		const GLint 		*intValues;

// Int Vectors
- (GLValue*)initWithInt:(GLint)x;
- (GLValue*)initVectorWithInts:(GLint)x :(GLint)y;
- (GLValue*)initVectorWithInts:(GLint)x :(GLint)y :(GLint)z;
- (GLValue*)initVectorWithInts:(GLint)x :(GLint)y :(GLint)z :(GLint)w;
- (GLValue*)initVectorWithInts:(const GLint*)px size:(GLsizei)size;
- (GLValue*)initVectorArrayWithInts:(const GLint*)px size:(GLsizei)size count:(GLsizei)count;

// Float Vectors
- (GLValue*)initWithFloat:(GLfloat)x;
- (GLValue*)initVectorWithFloats:(GLfloat)x :(GLfloat)y;
- (GLValue*)initVectorWithFloats:(GLfloat)x :(GLfloat)y :(GLfloat)z;
- (GLValue*)initVectorWithFloats:(GLfloat)x :(GLfloat)y :(GLfloat)z :(GLfloat)w;
- (GLValue*)initVectorWithFloats:(const GLfloat*)px size:(GLsizei)size;
- (GLValue*)initVectorArrayWithFloats:(const GLfloat*)px size:(GLsizei)size count:(GLsizei)count;

// Matrices
- (GLValue*)initMatrixWithFloats:(const GLfloat*)px size:(GLsizei)size;
- (GLValue*)initMatrixWithFloats:(const GLfloat*)px size:(GLsizei)size transpose:(BOOL)transpose;
- (GLValue*)initMatrixArrayWithFloats:(const GLfloat*)px size:(GLsizei)size count:(GLsizei)count;

// Convenience methods
+ (GLValue*)valueWithFloat:(GLfloat)x;
+ (GLValue*)vectorWithFloats:(GLfloat)x :(GLfloat)y;
+ (GLValue*)vectorWithFloats:(GLfloat)x :(GLfloat)y :(GLfloat)z;
+ (GLValue*)vectorWithFloats:(GLfloat)x :(GLfloat)y :(GLfloat)z :(GLfloat)w;
+ (GLValue*)vectorWithFloats:(const GLfloat*)px size:(GLsizei)size;
+ (GLValue*)matrixWithFloats:(const GLfloat*)px size:(GLsizei)size;
+ (GLValue*)matrixWithFloats:(const GLfloat*)px size:(GLsizei)size transpose:(BOOL)transpose;

+ (GLValue*)valueWithInt:(GLint)x;
+ (GLValue*)vectorWithInts:(GLint)x :(GLint)y;
+ (GLValue*)vectorWithInts:(GLint)x :(GLint)y :(GLint)z;
+ (GLValue*)vectorWithInts:(GLint)x :(GLint)y :(GLint)z :(GLint)w;
+ (GLValue*)vectorWithInts:(const GLint*)px size:(GLsizei)size;

// Loading values in current state
- (void)setUniformAtLocation:(GLint)location;
- (void)setAttributeAtLocation:(GLint)location;

@end
