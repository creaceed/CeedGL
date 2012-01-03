//
//  CeedGLDemoAppDelegate.h
//  CeedGLDemo
//
//  Created by Raphael Sebbe on 06/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CeedGLDemoAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
	
	IBOutlet NSOpenGLView *glView;
}

@property (retain) IBOutlet NSWindow *window;

@end
