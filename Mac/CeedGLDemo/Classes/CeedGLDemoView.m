//
//  CeedGLDemoView.m
//  CeedGL
//
//  Created by Raphael Sebbe on 06/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import "CeedGLDemoView.h"
#import <CeedGL/CeedGL.h>

#define STRINGIFY(A) [NSString stringWithCString:#A encoding:NSUTF8StringEncoding]

@implementation CeedGLDemoView

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

- (void)prepareOpenGL
{
	GLLogMethod();
	
	NSString *vertexShaderSource = 
	STRINGIFY(
			  attribute vec4 a_position;
			  attribute vec4 a_source_color;
			  varying vec4 v_destination_color;
			  uniform mat4 u_projection_matrix;
			  uniform mat4 u_modelview_matrix;
			  
			  void main(void)
			  {
				  v_destination_color = a_source_color;
				  gl_Position = u_projection_matrix * u_modelview_matrix * a_position;
			  }
			  );
	NSString *fragmentShaderSource = 
	STRINGIFY(
			  varying vec4 v_destination_color;
			  void main(void)
			  {
				  gl_FragColor = v_destination_color;
			  }  
	);
	
	program = [[GLProgram program] retain];
	
	NSError *error = nil;
	GLShader *vshader = [GLShader vertexShader], *fshader = [GLShader fragmentShader];
	
	[vshader setSource:vertexShaderSource];
	if(![vshader compile:&error]) { NSLog(@"Vertex shader compilation error: %@", error); }
	
	[fshader setSource:fragmentShaderSource];
	if(![fshader compile:&error]) { NSLog(@"Fragment shader compilation error: %@", error); }
	
	[program attachShader:vshader];
	[program attachShader:fshader];
	[program bindAttributeLocation:0 forName:@"a_position"];
	
	if(![program link:&error])  { NSLog(@"Could not link program error: %@", error); }
	
	
	command = [[GLDrawCommand drawCommand] retain];
	command.program = program;
	command.mode = GL_TRIANGLES;
	command.firstElement = 0;
	command.elementCount = 3;
	
	GLBuffer *attr = [GLBuffer buffer];
	GLfloat pos[] = {0,0, 	0.5,0,	0.5,1};
	[attr loadData:pos size:sizeof(pos) usage:GL_STATIC_DRAW target:GL_ARRAY_BUFFER];
	[command setAttributeBuffer:attr size:2 type:GL_FLOAT normalized:GL_FALSE stride:0 offset:0 forName:@"a_position"];
	
//	GLBuffer *colattr = [GLBuffer buffer];
//	GLfloat col[12] = {0,0,0,1, 	1,0,0,1,	0.5, 1,0,1};
//	[colattr loadData:col size:sizeof(col) usage:GL_STATIC_DRAW target:GL_ARRAY_BUFFER];
//	[command setAttributeBuffer:colattr size:4 type:GL_FLOAT normalized:GL_FALSE stride:0 offset:0 forName:@"a_source_color"];
	[command setAttribute:[GLValue vectorWithFloats:1 :0 :0 :1] forName:@"a_source_color"];
	
//	GLBuffer *indices = [GLBuffer buffer];
//	GLushort inds[3] = {0,1,2};
//	[indices loadData:inds size:sizeof(inds) usage:GL_STATIC_DRAW target:GL_ELEMENT_ARRAY_BUFFER];
//	[command setElementIndexes:indices type:GL_UNSIGNED_SHORT];
	
	
	GLfloat modelView[] = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
	GLfloat projection[] = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
	
	[command setUniform:[GLValue matrixWithFloats:modelView size:4] forName:@"u_modelview_matrix"];
	[command setUniform:[GLValue matrixWithFloats:projection size:4] forName:@"u_projection_matrix"];
	 
	
	glClearColor(0.1, 0.3, 0.5, 1);
}

- (void)reshape
{
	GLLogMethod();
	
	[[self openGLContext] makeCurrentContext];
	
	glViewport(0, 0, [self bounds].size.width, [self bounds].size.height);
	
}

- (void)drawRect:(NSRect)rect
{
	GLLogMethod();
	[[self openGLContext] makeCurrentContext];
	
	//glClearColor(0.5, 0.3, 0.5, 1);
	
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	//glMatrixMode(GL_MODELVIEW);
	//glLoadIdentity();
	//glOrtho(0, 1, 0, 1, -1, 1);
	[command draw];
	
//	glBegin(GL_TRIANGLES);
//	glVertex2f(0,0);
//	glVertex2f(0.5,0);
//	glVertex2f(0.5, 1);
//	glEnd();
	
	glSwapAPPLE();
}
	


@end
