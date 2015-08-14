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
