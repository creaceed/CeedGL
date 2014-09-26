//
//  GLDrawCommand.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLPlatform.h"

@class GLBuffer, GLProgram, GLTexture, GLValue;

@interface GLDrawCommand : NSObject {
	GLint 		mFirstElement, mElementCount;
	GLProgram 	*mProgram;
	GLBuffer 	*mElementIndexes;
	GLenum		mElementIndexType;				// GL_UNISGNED_BYTE, GL_UNSIGNED_SHORT, GL_UNSIGNED_INT (INT not on GL_ES)
	GLenum		mMode;				// ex. GL_LINES, GL_TRIANGLES
	
	NSMutableDictionary *mTextures;
	NSMutableDictionary *mUniforms;
	NSMutableDictionary *mAttributes;
    NSMutableDictionary *mUniformsDirtyState;
    NSMutableDictionary *mAttributesDirtyState;
}

@property (readwrite, nonatomic)			GLint 		firstElement, elementCount;
@property (readonly, nonatomic, retain) 	GLBuffer 	*elementIndexes;
@property (readonly, nonatomic) 			GLenum 		elementIndexType;
@property (readwrite, nonatomic)			GLenum 		mode;
@property (readwrite, nonatomic, retain)	GLProgram 	*program;

+ (GLDrawCommand*)drawCommand;

// Setting State
- (void)setElementIndexes:(GLBuffer*)buffer type:(GLenum)type;

- (void)setTexture:(GLTexture*)texture target:(GLenum)target unit:(GLenum)unit; // GL_TEXTURE0, ...
- (GLTexture*)textureForUnit:(GLenum)unit;
- (void)removeTextureForUnit:(GLenum)unit;
- (void)removeAllTextures;

- (void)setUniform:(GLValue*)value forName:(NSString*)name;
- (GLValue*)uniformForName:(NSString*)name;
- (void)removeUniformForName:(NSString*)name;
- (void)removeAllUniforms;

- (void)setAttribute:(GLValue*)value forName:(NSString*)name;
- (void)setAttributeBuffer:(GLBuffer*)buffer size:(GLint)size type:(GLenum)type normalized:(GLboolean)norm stride:(GLsizei)stride  offset:(GLsizeiptr)off forName:(NSString*)name;
- (id)attributeForName:(NSString*)name;
- (void)removeAttributeForName:(NSString*)name;
- (void)removeAllAttributes;

// Drawing
	// draw with attributes and internal program
- (void)draw;

	// draw with an overriding program, matching attributes and uniforms will be set appropriately
//- (void)drawWithProgram:(GLProgram*)program;


@end
