//
//  GLUtils.m
//  CeedGL
//
//  Created by Raphael Sebbe on 19/08/15.
//  Copyright © 2015 Creaceed. All rights reserved.
//

#import "GLUtils.h"
#import <CeedGL/GLPlatform.h>

@implementation GLUtils

+ (NSString*)rendererName {
	const GLubyte *s = glGetString(GL_RENDERER);
	return [NSString stringWithUTF8String:(const char *)s];
}
+ (NSString*)vendorName {
	const GLubyte *s = glGetString(GL_VENDOR);
	return [NSString stringWithUTF8String:(const char *)s];
}
+ (NSString*)versionString {
	const GLubyte *s = glGetString(GL_VERSION);
	return [NSString stringWithUTF8String:(const char *)s];
}

+ (NSString*)contextDescription {
	return [NSString stringWithFormat:@"%@ - %@ - %@", self.vendorName, self.rendererName, self.versionString];
}

- (instancetype)init {
	GL_EXCEPT(YES, @"should not be instantiated");
	return nil;
}

@end
