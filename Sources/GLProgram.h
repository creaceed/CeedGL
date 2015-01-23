//
//  GLProgram.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CeedGL/GLObject.h>

@class GLShader;

@interface GLProgram : GLObject {
    NSMutableDictionary *mAttachedShaders; // keys are the types as NSNumbers
	
	NSMutableDictionary *mUniformLookup;  // {name: location}
	NSMutableDictionary *mAttribLookup;  // {name: location}
}

+ (instancetype)program;

- (void)attachShader:(GLShader*)shader;
- (void)detachShaderWithType:(GLenum)type;
- (GLShader*)attachedShaderWithType:(GLenum)type;

// Convenience
- (GLShader*)vertexShader;
- (GLShader*)fragmentShader;

// Linking / Setting / Validate
- (BOOL)link:(NSError**)error;
- (void)use;
- (BOOL)validate:(NSError**)error;

// Variable Info (available after link)
- (void)bindAttributeLocation:(GLint)loc forName:(NSString*)name; // before linking!
- (NSArray*)allAttributeNames;
- (BOOL)hasAttributeNamed:(NSString*)name;
- (GLint)attributeLocationForName:(NSString*)name;
- (NSArray*)allUniformNames;
- (BOOL)hasUniformNamed:(NSString*)name;
- (GLint)uniformLocationForName:(NSString*)name;

@end
