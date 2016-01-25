//
//  GLDrawCommand.m
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <CeedGL/GLDrawCommand.h>
#import <CeedGL/GLProgram.h>
#import <CeedGL/GLValue.h>
#import <CeedGL/GLBuffer.h>
#import <CeedGL/GLTexture.h>

@implementation GLDrawCommand

@synthesize firstElement = mFirstElement, elementCount = mElementCount;
@synthesize elementIndexes = mElementIndexes, elementIndexType = mElementIndexType, mode = mMode, program = mProgram;

+ (instancetype)drawCommand
{
	return [[self alloc] init];
}

- (instancetype)init {
    if ((self = [super init])) {
        // Initialization code here.
		
		mTextures = [NSMutableDictionary new];
		mAttributes = [NSMutableDictionary new];
		mUniforms = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)dealloc {
	self.program = nil;
}

#pragma mark Indexes
- (void)setElementIndexes:(GLBuffer*)buffer type:(GLenum)type
{
	GL_EXCEPT(type != GL_UNSIGNED_BYTE && type != GL_UNSIGNED_SHORT && type != GL_UNSIGNED_INT, NSInvalidArgumentException);
	
	mElementIndexes = buffer;
	mElementIndexType = type;
}

#pragma mark Textures
- (void)setTexture:(GLTexture*)texture target:(GLenum)target unit:(GLenum)unit {
	GL_EXCEPT(texture.target != target, @"Target mismatch");
	[self setTexture:texture unit:unit];
}
- (void)setTexture:(GLTexture*)texture unit:(GLenum)unit
{
	GL_EXCEPT(texture == nil, NSInvalidArgumentException);
	id binder = [NSDictionary dictionaryWithObjectsAndKeys:texture, @"texture", nil];
	
	[mTextures setObject:binder forKey:[NSNumber numberWithInt:unit]];
}
- (GLTexture*)textureForUnit:(GLenum)unit
{
	return [[mTextures objectForKey:[NSNumber numberWithInt:unit]] objectForKey:@"texture"];
}
- (void)removeTextureForUnit:(GLenum)unit
{
	[mTextures removeObjectForKey:[NSNumber numberWithInt:unit]];
}
- (void)removeAllTextures
{
	[mTextures removeAllObjects];
}

#pragma mark Uniforms
- (void)setUniform:(GLValue*)value forName:(NSString*)name
{
	[mUniforms setObject:value forKey:name];
}
- (GLValue*)uniformForName:(NSString*)name
{
	return [mUniforms objectForKey:name];
}
- (void)removeUniformForName:(NSString*)name
{
	[mUniforms removeObjectForKey:name];
}
- (void)removeAllUniforms
{
	[mUniforms removeAllObjects];
}


#pragma mark Attributes
- (void)setAttribute:(GLValue*)value forName:(NSString*)name
{
	id binder = [NSDictionary dictionaryWithObjectsAndKeys:value, @"value", @"GLValue",@"kind", nil];
	
	[mAttributes setObject:binder forKey:name];
}
- (void)setAttributeBuffer:(GLBuffer*)buffer size:(GLint)size type:(GLenum)type normalized:(GLboolean)norm stride:(GLsizei)stride offset:(GLsizeiptr)off forName:(NSString*)name
{
	id binder = [NSDictionary dictionaryWithObjectsAndKeys:buffer, @"buffer", 
				 @"GLBuffer",@"kind", 
				 [NSNumber numberWithInt:size], @"size",
				 [NSNumber numberWithInt:type], @"type",
				 [NSNumber numberWithBool:norm], @"normalized",
				 [NSNumber numberWithInt:stride], @"stride",
				 [NSNumber numberWithInt:(int)off], @"offset",
				 nil];
	
	[mAttributes setObject:binder forKey:name];
}
- (id)attributeForName:(NSString*)name
{
	id binder = [mAttributes objectForKey:name];
	
	if([[binder objectForKey:@"kind"] isEqual:@"GLBuffer"]) return [binder objectForKey:@"buffer"];
	else return [binder objectForKey:@"value"]; 
}
- (void)removeAttributeForName:(NSString*)name
{
	[mAttributes removeObjectForKey:name];
}
- (void)removeAllAttributes
{
	[mAttributes removeAllObjects];
}

#pragma mark Drawing
- (void)draw
{
	GLProgram *prog = mProgram;

	GLCheckError();
	
	[prog use];
	
	GLCheckError();
	
	[mUniforms enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		*stop = NO;
		
		if([prog hasUniformNamed:key])
		{
			//GLLog(@"Setting value %@ to uniform %@", obj, key);
			[(GLValue*)obj setUniformAtLocation:[prog uniformLocationForName:key]];
		}
		else {
			GLLogWarning(@"Trying to set non existent uniform (%@), ignoring...", key);
		}

	}];
	
	
	//glVertexAttrib4f(0, 1, 0, 0, 1); // color, temp
	GLCheckError();
	
	[mAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		*stop = NO;
		if([prog hasAttributeNamed:key])
		{
			GLint loc = [prog attributeLocationForName:key];
			if([[obj objectForKey:@"kind"] isEqual:@"GLValue"])
			{
				GLValue *value = [obj objectForKey:@"value"];
				
				//glBindBuffer(GL_ARRAY_BUFFER, 0);
				//GLLog(@"Setting value %@ to attribute %@", value, key);
				[value setAttributeAtLocation:loc];
				glDisableVertexAttribArray(loc);
			}
			else {
				GLBuffer *buffer = [obj objectForKey:@"buffer"];
				
				[buffer bind:GL_ARRAY_BUFFER];
				//glBindBuffer(GL_ARRAY_BUFFER, buffer.handle);
				glVertexAttribPointer(loc, 
									  [[obj objectForKey:@"size"] intValue],
									  [[obj objectForKey:@"type"] intValue],
									  [[obj objectForKey:@"normalized"] boolValue], 
									  [[obj objectForKey:@"stride"] intValue],
									  (void*)[[obj objectForKey:@"offset"] integerValue]);
				glEnableVertexAttribArray(loc);
			}
		}
		else {
			//GLLog(@"Trying to set non existent attribute (%@), ignoring...", key);
		}
	}];
	
	GLCheckError();
	
	[mTextures enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		GLTexture *texture = [obj objectForKey:@"texture"];
	
//		GLCheckError();
		
		// should not be passed in modern profile OpenGL. Only for fixed-function pipeline, which we don't handle.
//		glEnable(GL_TEXTURE_3D);
		glActiveTexture([key intValue]); // unit
//		glBindTexture(GL_TEXTURE_1D, 0);
//		glBindTexture(GL_TEXTURE_2D, 0);
//		glBindTexture(GL_TEXTURE_3D, 0);
		[texture bind];
	}];
	
	GLCheckError();
	
	if(mElementCount > 0)
	{
//		glValidateProgram(prog.handle);
//		GLint res = 0;
//		glGetProgramiv(prog.handle, GL_VALIDATE_STATUS, &res);
//		GLLog(@"validate: %d", res);
		
		if(mElementIndexes)
		{
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mElementIndexes.handle);
			glDrawElements(mMode, mElementCount, mElementIndexType, (void*)(size_t)mFirstElement);
		}
		else {
			glDrawArrays(mMode, mFirstElement, mElementCount);
			GLCheckError();
		}
	}
	else {
		GLLogWarning(@"Trying to draw empty array, forgot to set firstElement/elementCount");
	}

	
	// may need to make that optional with some API.
	BOOL unbindTextures = YES;
	if(unbindTextures) {
		[mTextures enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			glActiveTexture([key intValue]); // unit
			GLTexture *texture = [obj objectForKey:@"texture"];
			[texture unbind];
//			[GLTexture unbind:[[obj objectForKey:@"target"] intValue]];
		}];
	}
}
//- (void)drawWithProgram:(GLProgram*)program
//{
//	
//}

@end
