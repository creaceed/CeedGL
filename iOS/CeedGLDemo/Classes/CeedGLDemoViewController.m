//
//  CeedGLDemoViewController.m
//  CeedGLDemo
//
//  Created by Raphael Sebbe on 07/11/10.
//  Copyright 2010 Creaceed. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CeedGLDemoViewController.h"
#import "EAGLView.h"

#define STRINGIFY(A) [NSString stringWithCString:#A encoding:NSUTF8StringEncoding]

// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

@interface CeedGLDemoViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
//- (BOOL)loadShaders;
//- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
//- (BOOL)linkProgram:(GLuint)prog;
//- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation CeedGLDemoViewController

@synthesize animating, context, displayLink;

- (void)prepareDrawCommand
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

- (void)awakeFromNib
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
//    if (!aContext)
//    {
//        aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
//    }
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
 //   if ([context API] == kEAGLRenderingAPIOpenGLES2)
//        [self loadShaders];
    
	[self prepareDrawCommand];
	
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;
}

- (void)dealloc
{
//    if (program)
//    {
//        glDeleteProgram(program);
//        program = 0;
//    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
//    if (program)
//    {
//        glDeleteProgram(program);
//        program = 0;
//    }

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        CADisplayLink *aDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
    
	glClearColor(0, 0, 0.3, 1.0);
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	//glMatrixMode(GL_MODELVIEW);
	//glLoadIdentity();
	//glOrtho(0, 1, 0, 1, -1, 1);
	[command draw];
	
 //   // Replace the implementation of this method to do your own custom drawing.
//    static const GLfloat squareVertices[] = {
//        -0.5f, -0.33f,
//        0.5f, -0.33f,
//        -0.5f,  0.33f,
//        0.5f,  0.33f,
//    };
//    
//    static const GLubyte squareColors[] = {
//        255, 255,   0, 255,
//        0,   255, 255, 255,
//        0,     0,   0,   0,
//        255,   0, 255, 255,
//    };
//    
//    static float transY = 0.0f;
//    
//    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
//    glClear(GL_COLOR_BUFFER_BIT);
//    
//    if ([context API] == kEAGLRenderingAPIOpenGLES2)
//    {
//        // Use shader program.
//        glUseProgram(program);
//        
//        // Update uniform value.
//        glUniform1f(uniforms[UNIFORM_TRANSLATE], (GLfloat)transY);
//        transY += 0.075f;	
//        
//        // Update attribute values.
//        glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
//        glEnableVertexAttribArray(ATTRIB_VERTEX);
//        glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, 1, 0, squareColors);
//        glEnableVertexAttribArray(ATTRIB_COLOR);
//        
//        // Validate program before drawing. This is a good check, but only really necessary in a debug build.
//        // DEBUG macro must be defined in your debug configurations if that's not already the case.
//#if defined(DEBUG)
//        if (![self validateProgram:program])
//        {
//            NSLog(@"Failed to validate program: %d", program);
//            return;
//        }
//#endif
//    }
//    else
//    {
//        glMatrixMode(GL_PROJECTION);
//        glLoadIdentity();
//        glMatrixMode(GL_MODELVIEW);
//        glLoadIdentity();
//        glTranslatef(0.0f, (GLfloat)(sinf(transY)/2.0f), 0.0f);
//        transY += 0.075f;
//        
//        glVertexPointer(2, GL_FLOAT, 0, squareVertices);
//        glEnableClientState(GL_VERTEX_ARRAY);
//        glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
//        glEnableClientState(GL_COLOR_ARRAY);
//    }
//    
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [(EAGLView *)self.view presentFramebuffer];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

//- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
//{
//    GLint status;
//    const GLchar *source;
//    
//    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
//    if (!source)
//    {
//        NSLog(@"Failed to load vertex shader");
//        return FALSE;
//    }
//    
//    *shader = glCreateShader(type);
//    glShaderSource(*shader, 1, &source, NULL);
//    glCompileShader(*shader);
//    
//#if defined(DEBUG)
//    GLint logLength;
//    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0)
//    {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetShaderInfoLog(*shader, logLength, &logLength, log);
//        NSLog(@"Shader compile log:\n%s", log);
//        free(log);
//    }
//#endif
//    
//    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
//    if (status == 0)
//    {
//        glDeleteShader(*shader);
//        return FALSE;
//    }
//    
//    return TRUE;
//}

//- (BOOL)linkProgram:(GLuint)prog
//{
//    GLint status;
//    
//    glLinkProgram(prog);
//    
//#if defined(DEBUG)
//    GLint logLength;
//    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0)
//    {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetProgramInfoLog(prog, logLength, &logLength, log);
//        NSLog(@"Program link log:\n%s", log);
//        free(log);
//    }
//#endif
//    
//    glGetProgramiv(prog, GL_LINK_STATUS, &status);
//    if (status == 0)
//        return FALSE;
//    
//    return TRUE;
//}

//- (BOOL)validateProgram:(GLuint)prog
//{
//    GLint logLength, status;
//    
//    glValidateProgram(prog);
//    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0)
//    {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetProgramInfoLog(prog, logLength, &logLength, log);
//        NSLog(@"Program validate log:\n%s", log);
//        free(log);
//    }
//    
//    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
//    if (status == 0)
//        return FALSE;
//    
//    return TRUE;
//}
//
//- (BOOL)loadShaders
//{
//    GLuint vertShader, fragShader;
//    NSString *vertShaderPathname, *fragShaderPathname;
//    
//    // Create shader program.
//    program = glCreateProgram();
//    
//    // Create and compile vertex shader.
//    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
//    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
//    {
//        NSLog(@"Failed to compile vertex shader");
//        return FALSE;
//    }
//    
//    // Create and compile fragment shader.
//    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
//    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
//    {
//        NSLog(@"Failed to compile fragment shader");
//        return FALSE;
//    }
//    
//    // Attach vertex shader to program.
//    glAttachShader(program, vertShader);
//    
//    // Attach fragment shader to program.
//    glAttachShader(program, fragShader);
//    
//    // Bind attribute locations.
//    // This needs to be done prior to linking.
//    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
//    glBindAttribLocation(program, ATTRIB_COLOR, "color");
//    
//    // Link program.
//    if (![self linkProgram:program])
//    {
//        NSLog(@"Failed to link program: %d", program);
//        
//        if (vertShader)
//        {
//            glDeleteShader(vertShader);
//            vertShader = 0;
//        }
//        if (fragShader)
//        {
//            glDeleteShader(fragShader);
//            fragShader = 0;
//        }
//        if (program)
//        {
//            glDeleteProgram(program);
//            program = 0;
//        }
//        
//        return FALSE;
//    }
//    
//    // Get uniform locations.
//    uniforms[UNIFORM_TRANSLATE] = glGetUniformLocation(program, "translate");
//    
//    // Release vertex and fragment shaders.
//    if (vertShader)
//        glDeleteShader(vertShader);
//    if (fragShader)
//        glDeleteShader(fragShader);
//    
//    return TRUE;
//}

@end
