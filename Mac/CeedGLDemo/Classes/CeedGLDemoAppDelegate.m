//
//  CeedGLDemoAppDelegate.m
//  CeedGLDemo
//
//  Created by Raphael Sebbe on 06/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import "CeedGLDemoAppDelegate.h"

@implementation CeedGLDemoAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}

- (void)dealloc {

	[window release];
    [super dealloc];
}

@end
