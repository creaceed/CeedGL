About CeedGL
============

CeedGL is a library that encapsulates OpenGL objects into Objective-C objects. It does not attempt to force a coding style or to define a specific scene graph, but instead aims at making it easier to work with OpenGL from Objective-C.

Modern OpenGL (ES 2.0, Desktop 3.0) defines a number of "objects", that is, vertex buffers, textures, shaders, programs, framebuffers, etc. that are typically represented by handles (integers). CeedGL proposes to model all these and their relationships with each other as actual Objective-C objects and associated methods. This in turn makes it easier to store and manipulate GL data in your app structure.

CeedGL also defines the concept of "draw command" which ties together vertex buffers, textures, shaders to provide reusable drawing primitives. It also makes it easier to access uniforms and attributes in shaders.

Finally, CeedGL should complement GLKit nicely on iPhone, although it is not required.

Requirements
------------
CeedGL is written in Objective-C and should run on most compiler and tool versions. The provided Xcode project and sample apps are made for iOS5 / Mac OS X 10.7.

Using CeedGL in your app
--------------------------
CeedGL project has been setup in a way that you can directly add it to your own application project. This enables easier updates of CeedGL with no need of separate build and file import (although you can still do it if that's what you want). 

Steps to include CeedGL:

* import the CeedGL project in your app project
* in your app target, add libCeedGL (or the framework) to the link phase (this creates an implicit build dependency)
* in your target build settings, add the following header search path (quotes matter):
	* `"$(CONFIGURATION_BUILD_DIR)/usr/local/include"`
	* `"$(DSTROOT)/usr/local/include"`
* you can then import CeedGL in your source file:
	* `#import <CeedGL/CeedGL.h>`

A code example
--------------
Here's an Objective-C code example for setting up a draw command:

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
			  varying lowp vec4 v_destination_color;
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

	[command setAttribute:[GLValue vectorWithFloats:1 :0 :0 :1] forName:@"a_source_color"];

	GLfloat modelView[] = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
	GLfloat projection[] = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

	[command setUniform:[GLValue matrixWithFloats:modelView size:4] forName:@"u_modelview_matrix"];
	[command setUniform:[GLValue matrixWithFloats:projection size:4] forName:@"u_projection_matrix"];

And here is how the draw command is invoked:
	
	- (void)drawFrame
	{
		[(EAGLView *)self.view setFramebuffer];

		glClearColor(0, 0, 0.3, 1.0);

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		[command draw];
	}

Why that name?
--------------
Well, it's how we name our reusable libs, both the internal and public ones here at Creaceed. English suffix "ceed" (as found in "succeed", "exceed", etc.) comes from Latin word "cedere", which means: to yield.

What's next?
------------
CeedGL is made to evolve. Feel free to add new methods, new types, or any other evolution. It is far from complete, but it provides a good starting point in the case you need modern OpenGL programming in your iPhone or Mac project.

