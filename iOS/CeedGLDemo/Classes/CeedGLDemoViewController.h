//
//  CeedGLDemoViewController.h
//  CeedGLDemo
//
//  Created by Raphael Sebbe on 07/11/10.
//  Copyright 2010 Creaceed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CeedGL/CeedGL.h>

#import <OpenGLES/EAGL.h>

//#import <OpenGLES/ES1/gl.h>
//#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface CeedGLDemoViewController : UIViewController
{
    EAGLContext *context;
//    GLuint program;
	GLProgram *program;
	GLDrawCommand *command;
	
	
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;

@end
