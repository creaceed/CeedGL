//
//  GLShader.m
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import "GLShader.h"


@implementation GLShader
@synthesize type = mType, source = mSource;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}
- (void)dealloc {
    // Clean-up code here.
    [mSource release];
	
    [super dealloc];
}
- (GLShader*)initWithType:(GLenum)type
{
    if ((self = [super init])) {
        // Initialization code here.
		mType = type;
    }
    
    return self;
}
- (GLShader*)initVertexShader
{
	return [self initWithType:GL_VERTEX_SHADER];
}
- (GLShader*)initFragmentShader
{
	return [self initWithType:GL_FRAGMENT_SHADER];
}

+ (GLShader*)vertexShader
{
	return [[[self alloc] initVertexShader] autorelease];
}
+ (GLShader*)fragmentShader
{
	return [[[self alloc] initFragmentShader] autorelease];
}



#pragma mark -
#pragma mark Handle creation/destruction
- (void)createHandle
{
	GL_EXCEPT(mHandle, @"Trying to create a new handle over an existing one");
	
	mHandle = glCreateShader(mType);
	
	GL_EXCEPT(!mHandle, @"Could not create handle (no current GL context?)"); 
}
- (void)destroyHandle
{
	GL_EXCEPT(!mHandle, @"Trying to destroy a NULL handle");
	
	glDeleteShader(mHandle);
	mHandle = 0;
}

#pragma mark Code
- (void)setSource:(NSString*)source
{
	if(mHandle == 0) 
		[self createHandle];
	
	const char *s = [source cStringUsingEncoding:NSUTF8StringEncoding];
	glShaderSource(mHandle, 1, &s, NULL);
	
}
- (BOOL)compile:(NSError**)error
{
	GL_EXCEPT(!mHandle, @"Trying to compile a NULL handle");
	
	glCompileShader(mHandle);
	
	GLint res = 0;
	glGetShaderiv(mHandle, GL_COMPILE_STATUS, &res);
	
	if(res == GL_TRUE) return YES;
	else
	{
		GLchar info[512] = "";
		GLsizei l = 511;
		glGetShaderInfoLog(mHandle, l, &l, info);
		
		NSString *msg = [NSString stringWithCString:info encoding:NSUTF8StringEncoding];
		GLLog(@"Compiler message: %@", msg);
		
		if(error && msg)
		{
			*error = [NSError errorWithDomain:@"CeedGL" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil]];
		}
		
		return NO;
	}
}


@end
