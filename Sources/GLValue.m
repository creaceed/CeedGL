//
//  GLValue.m
//  CeedGL
//
//  Created by Raphael Sebbe on 06/11/10.
//  Copyright 2010 Creaceed. All rights reserved.
//

#import "GLValue.h"
#import "GLDebug.h"

#define mINT_ARRAY ((GLint*)mValues)

@implementation GLValue

@synthesize size = mSize;
@synthesize isMatrix = mIsMatrix, isArray = mIsArray;

- (void)dealloc
{
	[mValuesArrayData release];
	
	[super dealloc];
}

- (NSString*)description
{
	// should handle various types correctly here
	return [NSString stringWithFormat:@"(%f %f %f %f)", mValues[0], mValues[1], mValues[2], mValues[3]];
}

#pragma mark Int Vectors
- (GLValue*)initWithInt:(GLint)x
{
	if((self = [super init]))
	{
		mINT_ARRAY[0] = x;
		mSize = 1;
		mCount = 1;
		mType = GL_INT;
	}
	return self;
}
- (GLValue*)initVectorWithInts:(GLint)x :(GLint)y
{
	if((self = [super init]))
	{
		mINT_ARRAY[0] = x;
		mINT_ARRAY[1] = y;
		mSize = 2;
		mCount = 1;
		mType = GL_INT;
	}
	return self;
}
- (GLValue*)initVectorWithInts:(GLint)x :(GLint)y :(GLint)z
{
	if((self = [super init]))
	{
		mINT_ARRAY[0] = x;
		mINT_ARRAY[1] = y;
		mINT_ARRAY[2] = z;
		mSize = 3;
		mCount = 1;
		mType = GL_INT;
	}
	return self;
}
- (GLValue*)initVectorWithInts:(GLint)x :(GLint)y :(GLint)z :(GLint)w
{
	if((self = [super init]))
	{
		mINT_ARRAY[0] = x;
		mINT_ARRAY[1] = y;
		mINT_ARRAY[2] = z;
		mINT_ARRAY[3] = w;
		mSize = 4;
		mCount = 1;
		mType = GL_INT;
	}
	return self;
}
- (GLValue*)initVectorWithInts:(const GLint*)px size:(GLsizei)size
{
	GL_EXCEPT(size <= 0 || size > 4, NSInvalidArgumentException);
	GL_EXCEPT(px == NULL, NSInvalidArgumentException);
	
	if((self = [super init]))
	{
		memcpy(mINT_ARRAY, px, sizeof(GLint) * size);
		mSize = size;
		mCount = 1;
		mType = GL_INT;
	}
	return self;
}
- (GLValue*)initVectorArrayWithInts:(const GLint*)px size:(GLsizei)size count:(GLsizei)count
{
	GL_EXCEPT(size <= 0 || size > 4, NSInvalidArgumentException);
	GL_EXCEPT(px == NULL, NSInvalidArgumentException);
	GL_EXCEPT(count == 0, NSInvalidArgumentException);
	
	if((self = [super init]))
	{
		mValuesArrayData = [[NSData dataWithBytes:px length:size*count*sizeof(GLint)] retain];
		mSize = size;
		mCount = count;
		mType = GL_INT;
		mIsArray = YES;
	}
	return self;
}

#pragma mark Float Vectors
- (GLValue*)initWithFloat:(GLfloat)x
{
	if((self = [super init]))
	{
		mValues[0] = x;
		mSize = 1;
		mCount = 1;
		mType = GL_FLOAT;
	}
	return self;	
}
- (GLValue*)initVectorWithFloats:(GLfloat)x :(GLfloat)y
{
	if((self = [super init]))
	{
		mValues[0] = x;
		mValues[1] = y;
		mSize = 2;
		mCount = 1;
		mType = GL_FLOAT;
	}
	return self;
}
- (GLValue*)initVectorWithFloats:(GLfloat)x :(GLfloat)y :(GLfloat)z
{
	if((self = [super init]))
	{
		mValues[0] = x;
		mValues[1] = y;
		mValues[2] = z;
		mSize = 3;
		mCount = 1;
		mType = GL_FLOAT;
	}
	return self;
}
- (GLValue*)initVectorWithFloats:(GLfloat)x :(GLfloat)y :(GLfloat)z :(GLfloat)w
{
	if((self = [super init]))
	{
		mValues[0] = x;
		mValues[1] = y;
		mValues[2] = z;
		mValues[3] = w;
		mSize = 4;
		mCount = 1;
		mType = GL_FLOAT;
	}
	return self;
}
- (GLValue*)initVectorWithFloats:(const GLfloat*)px size:(GLsizei)size
{
	GL_EXCEPT(size <= 0 || size > 4, NSInvalidArgumentException);
	GL_EXCEPT(px == NULL, NSInvalidArgumentException);
	
	if((self = [super init]))
	{
		memcpy(mValues, px, sizeof(GLfloat) * size);
		mSize = size;
		mCount = 1;
		mType = GL_FLOAT;
	}
	return self;
}
- (GLValue*)initVectorArrayWithFloats:(const GLfloat*)px size:(GLsizei)size count:(GLsizei)count
{
	GL_EXCEPT(size <= 0 || size > 4, NSInvalidArgumentException);
	GL_EXCEPT(px == NULL, NSInvalidArgumentException);
	GL_EXCEPT(count == 0, NSInvalidArgumentException);
	
	if((self = [super init]))
	{
		mValuesArrayData = [[NSData dataWithBytes:px length:size*count*sizeof(GLfloat)] retain];
		mSize = size;
		mCount = count;
		mType = GL_FLOAT;
		mIsArray = YES;
	}
	return self;
}

#pragma mark Matrices
- (GLValue*)initMatrixWithFloats:(const GLfloat*)px size:(GLsizei)size
{
	return [self initMatrixWithFloats:px size:size transpose:NO];
}
- (GLValue*)initMatrixWithFloats:(const GLfloat*)px size:(GLsizei)size transpose:(BOOL)transpose
{
	GL_EXCEPT(size <= 0 || size > 4, NSInvalidArgumentException);
	GL_EXCEPT(px == NULL, NSInvalidArgumentException);
	
	if((self = [super init]))
	{
		if(transpose)
		{
			int i;
			
			for(i=0; i<size*size; i++)
				mValues[i] = px[i/size + size*(i%size)];
		}
		else memcpy(mValues, px, size*size*sizeof(GLfloat));
		mSize = size;
		mCount = 1;
		mType = GL_FLOAT;
		mIsMatrix = YES;
	}
	
	return self;
}
- (GLValue*)initMatrixArrayWithFloats:(const GLfloat*)px size:(GLsizei)size count:(GLsizei)count
{
	GL_EXCEPT(size <= 1 || size > 4, NSInvalidArgumentException);
	GL_EXCEPT(px == NULL, NSInvalidArgumentException);
	GL_EXCEPT(count == 0, NSInvalidArgumentException);
	
	if((self = [super init]))
	{
		mValuesArrayData = [[NSData dataWithBytes:px length:size*size*sizeof(GLfloat)*count] retain];
		mSize = size;
		mCount = count;
		mType = GL_FLOAT;
		mIsArray = YES;
		mIsMatrix = YES;
	}
	return self;
}

// Convenience methods
+ (GLValue*)valueWithFloat:(GLfloat)x
{
	return [[[self alloc] initWithFloat:x] autorelease];
}
+ (GLValue*)vectorWithFloats:(GLfloat)x :(GLfloat)y
{
	return [[[self alloc] initVectorWithFloats:x :y] autorelease];
}
+ (GLValue*)vectorWithFloats:(GLfloat)x :(GLfloat)y :(GLfloat)z
{
	return [[[self alloc] initVectorWithFloats:x :y :z] autorelease];
}
+ (GLValue*)vectorWithFloats:(GLfloat)x :(GLfloat)y :(GLfloat)z :(GLfloat)w
{
	return [[[self alloc] initVectorWithFloats:x :y :z :w] autorelease];
}
+ (GLValue*)vectorWithFloats:(const GLfloat*)px size:(GLsizei)size
{
	return [[[self alloc] initVectorWithFloats:px size:size] autorelease];
}
+ (GLValue*)matrixWithFloats:(const GLfloat*)px size:(GLsizei)size
{
	return [[[self alloc] initMatrixWithFloats:px size:size] autorelease];
}
+ (GLValue*)matrixWithFloats:(const GLfloat*)px size:(GLsizei)size transpose:(BOOL)transpose
{
	return [[[self alloc] initMatrixWithFloats:px size:size transpose:transpose] autorelease];
}
+ (GLValue*)valueWithInt:(GLint)x
{
	return [[[self alloc] initWithInt:x] autorelease];
}
+ (GLValue*)vectorWithInts:(GLint)x :(GLint)y
{
	return [[[self alloc] initVectorWithInts:x :y] autorelease];
}
+ (GLValue*)vectorWithInts:(GLint)x :(GLint)y :(GLint)z
{
	return [[[self alloc] initVectorWithInts:x :y :z] autorelease];
}
+ (GLValue*)vectorWithInts:(GLint)x :(GLint)y :(GLint)z :(GLint)w
{
	return [[[self alloc] initVectorWithInts:x :y :z :w] autorelease];
}
+ (GLValue*)vectorWithInts:(const GLint*)px size:(GLsizei)size
{
	return [[[self alloc] initVectorWithInts:px size:size] autorelease];
}
#pragma mark Accessors
- (BOOL)isVector { return !mIsMatrix; }

- (const GLfloat*)floatValues
{
	GL_EXCEPT(mType != GL_FLOAT, NSInvalidArgumentException);
	
	return mIsArray?[mValuesArrayData bytes]:mValues;
}
- (const GLint*)intValues
{
	GL_EXCEPT(mType != GL_INT, NSInvalidArgumentException);
	
	return mIsArray?[mValuesArrayData bytes]:mINT_ARRAY;
}

// Loading values in current state
- (void)setUniformAtLocation:(GLint)location
{
	if(mIsMatrix)
	{
		if(mType == GL_FLOAT)
		{
			if(mSize == 2) glUniformMatrix2fv(location, mCount, GL_FALSE, self.floatValues);
			else if(mSize == 3) glUniformMatrix3fv(location, mCount, GL_FALSE, self.floatValues);
			else if(mSize == 4) glUniformMatrix4fv(location, mCount, GL_FALSE, self.floatValues);
			else {GL_EXCEPT(1, NSInternalInconsistencyException);}
		}	
		else {GL_EXCEPT(1, NSInternalInconsistencyException);}
	}
	else
	{
		if(mType == GL_FLOAT)
		{
			if(mSize == 1) glUniform1fv(location, mCount, self.floatValues);
			else if(mSize == 2) glUniform2fv(location, mCount, self.floatValues);
			else if(mSize == 3) glUniform3fv(location, mCount, self.floatValues);
			else if(mSize == 4) glUniform4fv(location, mCount, self.floatValues);
			else {GL_EXCEPT(1, NSInternalInconsistencyException);}
		}
		else if(mType == GL_INT)
		{
			if(mSize == 1) glUniform1iv(location, mCount, self.intValues);
			else if(mSize == 2) glUniform2iv(location, mCount, self.intValues);
			else if(mSize == 3) glUniform3iv(location, mCount, self.intValues);
			else if(mSize == 4) glUniform4iv(location, mCount, self.intValues);
			else {GL_EXCEPT(1, NSInternalInconsistencyException);}
		}
		else {GL_EXCEPT(1, NSInternalInconsistencyException);}
	}
}
- (void)setAttributeAtLocation:(GLint)location
{
	GL_EXCEPT(mIsMatrix, NSInternalInconsistencyException); // TODO: matrix column loading not implemented yet, remove that when done
	GL_EXCEPT(mIsArray, NSInvalidArgumentException); 
	GL_EXCEPT(mType != GL_FLOAT, NSInvalidArgumentException); 
	
	if(mType == GL_FLOAT)
	{
		if(mSize == 1) glVertexAttrib1fv(location, self.floatValues);
		else if(mSize == 2) glVertexAttrib2fv(location, self.floatValues);
		else if(mSize == 3) glVertexAttrib3fv(location, self.floatValues);
		else if(mSize == 4) glVertexAttrib4fv(location, self.floatValues);
		else {GL_EXCEPT(1, NSInternalInconsistencyException);}
	}
	else {GL_EXCEPT(1, NSInternalInconsistencyException);}
}

@end
