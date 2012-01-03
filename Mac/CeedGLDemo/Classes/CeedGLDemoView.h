//
//  CeedGLDemoView.h
//  CeedGL
//
//  Created by Raphael Sebbe on 06/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CeedGL/CeedGL.h>

@interface CeedGLDemoView : NSOpenGLView {
    GLProgram *program;
	GLDrawCommand *command;
	
}

@end
