
#define GL_DEPRECATED __attribute__((deprecated))
#define GL_DEPRECATED_MSG(msg) __attribute((deprecated((msg))))

// Mac Options
#define USE_CORE_PROFILE_32 0 // not using it as default because it's incompatible with GL-based CIContext

// iOS Options
#define USE_GLES3 0

#if TARGET_OS_IPHONE
	//#define USE_GLES3
	#define GL_IOS 1
	#define GL_MAC 0

	#import <OpenGLES/EAGL.h>
	#if USE_GLES3
		#import <OpenGLES/ES3/gl.h>
		#import <OpenGLES/ES3/glext.h>
	#else
		#import <OpenGLES/ES2/gl.h>
		#import <OpenGLES/ES2/glext.h>
	#endif
#else
	#define GL_IOS 0
	#define GL_MAC 1

	#import <OpenGL/OpenGL.h>
	#if USE_CORE_PROFILE_32
		#import <OpenGL/gl3.h>
		#import <OpenGL/gl3ext.h>
	#else
		#import <OpenGL/gl.h>
		#import <OpenGL/glext.h>
	#endif /* Core Profile 3.2 */
#endif

// Handling of C++
#if defined(__cplusplus)
	#define GL_EXTERN extern "C"
#else
	#define GL_EXTERN extern
#endif
