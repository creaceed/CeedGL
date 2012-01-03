//
//  GLDebug.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
	
extern void ex_debug_terminate();
	
#ifdef __cplusplus
}
#endif

#ifdef DEBUG
#define GL_ASSERT(condition)\
{\
if(!(condition)) \
{ \
NSString *s = [NSString stringWithFormat:@"File: %s, Line: %d \nCondition: (%s)\n\n",\
__FILE__, __LINE__, #condition];\
NSLog(@"Debugging... %@",s);\
ex_debug_terminate();\
exit(1); \
}\
}
#define GLDebugRequire GL_ASSERT
#ifdef GL_DISABLE_LOG
#define GLLog(...)
#define GLLogMethod(...)
#define GLLogMethodArg(...)
#else
#define GLLog(...) { NSLog(@"    %@", [NSString stringWithFormat:__VA_ARGS__]); }
#define GLLogMethod() { NSLog(@"> %@", NSStringFromSelector(_cmd)); }
#define GLLogMethodArg(...) { NSLog(@"M %@, %@", NSStringFromSelector(_cmd), [NSString stringWithFormat:__VA_ARGS__]); }
#endif
#else
#define GL_ASSERT(condition)
#define GLDebugRequire GL_ASSERT
#define GLLog(...)
#define GLLogMethod(...)
#define GLLogMethodArg(...)
#endif

// raises an exception if condition is true
#define GL_EXCEPT(condition, exception) {if((condition)) [NSException raise:exception format:@""];}

