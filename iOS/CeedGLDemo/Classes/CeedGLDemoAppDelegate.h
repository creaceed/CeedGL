//
//  CeedGLDemoAppDelegate.h
//  CeedGLDemo
//
//  Created by Raphael Sebbe on 07/11/10.
//  Copyright 2010 Creaceed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CeedGLDemoViewController;

@interface CeedGLDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CeedGLDemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CeedGLDemoViewController *viewController;

@end

