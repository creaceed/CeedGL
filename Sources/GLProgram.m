//
//  GLProgram.m
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import "GLProgram.h"
#import "GLShader.h"

@implementation GLProgram

+ (GLProgram*)program
{
	return [[[self alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
		mAttachedShaders = [NSMutableDictionary new];
		mUniformLookup = [NSMutableDictionary new];
		mAttribLookup = [NSMutableDictionary new];

    }
    
    return self;
}

- (void)dealloc {
    [mAttachedShaders release];
	[mUniformLookup release];
	[mAttribLookup release];
	
	
    [super dealloc];
}

#pragma mark -
#pragma mark Handle creation/destruction
- (void)createHandle
{
	GL_EXCEPT(mHandle, @"Trying to create a new handle over an existing one");
	
	mHandle = glCreateProgram();
	
	GL_EXCEPT(!mHandle, @"Could not create handle (no current GL context?)"); 
}
- (void)destroyHandle
{
	GL_EXCEPT(!mHandle, @"Trying to destroy a NULL handle");
	
	glDeleteProgram(mHandle);
	mHandle = 0;
}

#pragma mark -
#pragma mark Program

- (void)attachShader:(GLShader*)shader
{
	GL_EXCEPT(shader == nil, NSInvalidArgumentException);
	
	if(mHandle == 0) 
		[self createHandle];
	
	if([self attachedShaderWithType:shader.type])
	{
		[self detachShaderWithType:shader.type];
	}
	
	glAttachShader(mHandle, shader.handle);
	[mAttachedShaders setObject:shader forKey:[NSNumber numberWithLong:shader.type]];
}
- (void)detachShaderWithType:(GLenum)type
{
	GL_EXCEPT(mHandle == 0, NSInternalInconsistencyException);
	
	GLShader *shader = [self attachedShaderWithType:type];
	if(shader)
	{
		glDetachShader(mHandle, shader.handle);
		[mAttachedShaders removeObjectForKey:[NSNumber numberWithLong:shader.type]];
	}
}
- (GLShader*)attachedShaderWithType:(GLenum)type
{
	return [mAttachedShaders objectForKey:[NSNumber numberWithLong:type]];
}

// Convenience
- (GLShader*)vertexShader
{
	return [self attachedShaderWithType:GL_VERTEX_SHADER];
}
- (GLShader*)fragmentShader
{
	return [self attachedShaderWithType:GL_FRAGMENT_SHADER];
}

- (void)bindAttributeLocation:(GLint)loc forName:(NSString*)name
{
	GL_EXCEPT(mHandle == 0, NSInternalInconsistencyException);
	
	glBindAttribLocation(mHandle, loc, [name cStringUsingEncoding:NSUTF8StringEncoding]);
}
- (BOOL)link:(NSError**)error
{
	//glBindAttribLocation(mHandle, 0, "a_position");
	//glBindAttribLocation(mHandle, 1, "a_source_color");
	
	GL_EXCEPT(mHandle == 0, NSInternalInconsistencyException);
	glLinkProgram(mHandle);
	
	GLint res = 0;
	glGetProgramiv(mHandle, GL_LINK_STATUS, &res);
	if(res == GL_TRUE) 
	{
		// build uniform / attribute name lookup
		GLint c = 0;
		
		[mUniformLookup removeAllObjects];
		glGetProgramiv(self.handle, GL_ACTIVE_UNIFORMS, &c);
		for(int i=0; i<c; i++)
		{
			GLsizei unamesize = 0;
			GLchar uname[256] = "";
			GLint size = 0, loc;
			GLenum type;

			glGetActiveUniform(mHandle, i, 256, &unamesize, &size, &type, uname);
			
			if(unamesize > 0)
			{
				loc = glGetUniformLocation(mHandle, uname);
				[mUniformLookup setObject:[NSNumber numberWithInt:loc] forKey:[NSString stringWithCString:uname encoding:NSUTF8StringEncoding]];
			}
		}
		//GLLog(@"Uniforms in program %d: %@", mHandle, mUniformLookup);
		
		[mAttribLookup removeAllObjects];
		glGetProgramiv(mHandle, GL_ACTIVE_ATTRIBUTES, &c);
		for(int i=0; i<c; i++)
		{
			GLsizei namesize = 0;
			GLchar name[256] = "";
			GLint size = 0, loc;
			GLenum type;
			
			glGetActiveAttrib(mHandle, i, 256, &namesize, &size, &type, name);
			
			if(namesize > 0)
			{
				loc = glGetAttribLocation(mHandle, name);
				[mAttribLookup setObject:[NSNumber numberWithInt:loc] forKey:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
			}
		}
		//GLLog(@"Attributes in program %d: %@", mHandle, mAttribLookup);
		
		return YES;
	}
	else
	{
		GLchar info[512] = "";
		GLsizei l = 511;
		glGetProgramInfoLog(mHandle, l, &l, info);
		
		NSString *msg = [NSString stringWithCString:info encoding:NSUTF8StringEncoding];
		//GLLog(@"Compiler message: %@", msg);
		
		if(error && msg)
		{
			*error = [NSError errorWithDomain:@"CeedGL" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil]];
		}
		
		return NO;
	}
}
- (void)use
{
	GL_EXCEPT(mHandle == 0, NSInternalInconsistencyException);
	glUseProgram(mHandle);
}

- (BOOL)validate:(NSError**)error
{
	GL_EXCEPT(mHandle == 0, NSInternalInconsistencyException);
	glValidateProgram(mHandle);
	
	GLint res = 0;
	glGetProgramiv(mHandle, GL_VALIDATE_STATUS, &res);
	//GLLog(@"validate: %d", res);
	if(res == GL_TRUE)
	{
		return YES;
	}
	else
	{
		GLchar info[512] = "";
		GLsizei l = 511;
		glGetProgramInfoLog(mHandle, l, &l, info);
		
		NSString *msg = [NSString stringWithCString:info encoding:NSUTF8StringEncoding];
		//GLLog(@"Validate message: %@", msg);
		
		if(error && msg)
		{
			*error = [NSError errorWithDomain:@"CeedGL" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil]];
		}
		
		return NO;
	}
}

- (NSArray*)allAttributeNames
{
	return [mAttribLookup allKeys];
}
- (BOOL)hasAttributeNamed:(NSString*)name
{
	return [mAttribLookup objectForKey:name] != nil;
}
- (GLint)attributeLocationForName:(NSString*)name
{
	id loc = [mAttribLookup objectForKey:name];
	
	if(loc)	return [loc intValue];
	else 
	{
		GL_EXCEPT(1, NSInvalidArgumentException);
		return 0;
	}
}
- (NSArray*)allUniformNames
{
	return [mUniformLookup allKeys];
}
- (BOOL)hasUniformNamed:(NSString*)name
{
	return [mUniformLookup objectForKey:name] != nil;
}
- (GLint)uniformLocationForName:(NSString*)name
{
	id loc = [mUniformLookup objectForKey:name];
	
	if(loc)	return [loc intValue];
	else 
	{
		GL_EXCEPT(1, NSInvalidArgumentException);
		return 0;
	}
}

@end
