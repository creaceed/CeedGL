//
//  GLTexture.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CeedGL/GLObject.h>

// Mapped from Metal types
typedef NS_ENUM(NSInteger, GLTextureKind) {
	GLTextureKind1D = 0,
	GLTextureKind1DArray = 1,
	GLTextureKind2D = 2,
	GLTextureKind2DArray = 3,
//	GLTextureKind2DMultisample = 4,
	GLTextureKindCubemap = 5,
//	GLTextureKindCubemapArray = 6,
	GLTextureKind3D = 7,
};

typedef NS_ENUM(NSInteger, GLTextureImageSource) {
	GLTextureImageSourceAllocateOnly, 	// just allocation, no init
	GLTextureImageSourceData,	// copies from memory
	GLTextureImageSourceFramebuffer,	// copies from currently bound framebuffer
};


typedef struct {
	GLint x, y, z;					// y, z set only for resp. >=2D and 3D kinds.
	GLsizei width, height, depth; 	// same thing for height & depth.
} GLTextureRange;

typedef struct {
	GLTextureKind kind; // 1D, 1DArray, 2D, 2DArray, 3D, CUBE_MAP. Note: a particular kind may have multiple possible targets (2D -> GL_TEXTURE_2D or GL_TEXTURE_Rect_2D)
	GLenum  target;	// cannot be 0
	GLsizei width;
	GLsizei height;
 	GLsizei depth;
	GLsizei arrayLength;
	GLenum  format;		// internal format
	GLenum  type;		// type (some implementation may need the type to be set before allocation)
	GLint border;
} GLTextureSpecifier;


typedef struct {
	GLenum format;		// if 0, native texture's format is used.
	GLenum type;		// if 0, native texture's type is used.
	GLint alignment;	// 1, 2, 4, or 8. If 0, 4 is used as default value. If -1, no change to current GL setting.
	const void *bytes;
} GLTextureData;

typedef struct {
	GLint mipmapLevel;
	GLTextureImageSource source;
	GLTextureData data; // only if source == Data or source == 
	struct {
		// offset for reading framebuffer. Only if source == Framebuffer
		GLint x, y;
	} framebuffer;
	struct {
		// CUBE_MAP only, in [0, 5]
		GLint face;
	} cubemap;
} GLTextureLoader;

typedef struct {
	GLTextureRange range;
	GLint mipmapLevel;
	GLTextureImageSource source; // AllocateOnly not supported
	GLTextureData data;
	struct {
		// offset for reading framebuffer. Only if source == Framebuffer
		GLint x, y;
	} framebuffer;
	struct {
		// CUBE_MAP only, in [0, 5]
		GLint face;
	} cubemap;
} GLTextureUpdater;

typedef enum {
	GLTextureFilterMaskMagnification = 0x1ULL << 0,
	GLTextureFilterMaskMinification = 0x1ULL << 1,
	GLTextureFilterMaskAll = GLTextureFilterMaskMagnification | GLTextureFilterMaskMinification,
} GLTextureFilterMask;

typedef enum {
	GLTextureWrapModeMaskS = 0x1ULL << 0,
	GLTextureWrapModeMaskT = 0x1ULL << 1,
	GLTextureWrapModeMaskR = 0x1ULL << 2,
	GLTextureWrapModeMaskAll = GLTextureWrapModeMaskS | GLTextureWrapModeMaskT | GLTextureWrapModeMaskR,
} GLTextureWrapModeMask;

typedef struct {
	struct {
		GLTextureWrapModeMask mask;
		GLenum s,t,r;
	} wrapMode;
	struct {
		GLTextureFilterMask mask;
		GLenum min, mag;
	} filter;
} GLTextureParameters;

// GLTextureKind methods
extern BOOL GLTextureKindIsArray(GLTextureKind kind);
extern int GLTextureKindGetDimension(GLTextureKind kind);

// GLTextureSpecifier methods
// We may need a bunch of additional ones here.
extern GLTextureSpecifier GLTextureSpecifierMakeEmpty(void);
extern GLTextureSpecifier GLTextureSpecifierMakeTexture2D(GLenum  target, GLsizei w, GLsizei h, GLenum format, GLenum type);
extern GLTextureSpecifier GLTextureSpecifierMakeTexture3D(GLenum  target, GLsizei w, GLsizei h, GLsizei d, GLenum format, GLenum type);

// GLTextureLoader & GLTextureUpdater methods
extern GLTextureLoader GLTextureLoaderMakeEmpty(void);
extern GLTextureLoader GLTextureLoaderMakeNativeData(void *data);	// data source, format and type derived from texture's

extern GLTextureUpdater GLTextureUpdaterMakeEmpty(void);
extern GLTextureUpdater GLTextureUpdaterMakeData2D(void *data, GLint xoff, GLint yoff, GLsizei width, GLsizei height);
extern GLTextureUpdater GLTextureUpdaterMakeData3D(void *data, GLint xoff, GLint yoff, GLint zoff, GLsizei width, GLsizei height, GLsizei depth);
// GLTextureParameters methods
extern GLTextureParameters GLTextureParametersMakeEmpty(void);
extern void GLTextureParametersSetFilter(GLTextureParameters *params, GLenum minFilter, GLenum magFilter);
extern void GLTextureParametersSetWrapMode2D(GLTextureParameters *params, GLenum s, GLenum t);
extern void GLTextureParametersSetWrapMode3D(GLTextureParameters *params, GLenum s, GLenum t, GLenum r);


@interface GLTexture : GLObject {
//	GLsizei 	mWidth, mHeight;
//	GLenum		mInternalFormat;			// ex. GL_RGBA
////	GLenum 		mType;						// ex. GL_UNSIGNED_BYTE
//	GLTextureKind mType;
//	GLint		mBorder;
//	GLenum		mTarget;					// 0 initially until it has been determined (setFromExisting / allocated / loaded / etc.).
}

@property (readonly, nonatomic) GLTextureKind kind;

@property (readonly, nonatomic) GLenum 		target;
@property (readonly, nonatomic) GLenum 		format, type; // Normally type shouldn't be stored with GL, but with GLES, it is necessary. (iOS format: GL_RGBA, type: GL_FLOAT. Mac format: GL_RGBA32F, but seems to accept GLES conventions, ie, a format/type pair). So we are basically making both of them required for texture specification.
@property (readonly, nonatomic) GLsizei 	width, height, depth; // depth is 1 if not 3D texture
@property (readonly, nonatomic) CGSize 		size; // 2D size (width, height)
//@property (readonly, nonatomic) GLenum 		internalFormat, type;
@property (readonly, nonatomic) GLint 		border;
@property (readonly, nonatomic) GLint 		arrayLength;

// This new GLTexture API is intended to manage all texture kinds (the previous API focused on 2D textures), hence the changes.

// GLTexture must be specified on creation (size, format, etc). Actual GPU handle allocation, data loading can be defered. In CeedGL, texture specification is considered immutable. Texture *contents* can be updated though.
// Remark: OpenGL accepts changing ie. texture size for a given handle in some circumstance. That cannot be performed in CeedGL. (in that case, create another GLTexture to represent it).
+ (instancetype)textureWithSpecifier:(GLTextureSpecifier)s;

//- (void)initializeWithExistingHandle:(GLint)handle;
//- (void)initializeWithImageData:(GLTextureLoader)loader;
//- (void)initializeEmptyStorage;

// ## Feeding initial texture data.
// These 3 methods allocate & (optionally) feed texture with data. Once (fully) fed, these cannot be invoked again, update should be invoked instead. Note that the loadImageData method may need to be invoked a number of times (ie, for each face in cubemap texture) or only once. setFromExistingHandle & allocateStorage do the full 'feeding' at once.

// Set texture handle from pre-created texture
- (void)setFromExistingHandle:(GLint)handle;

// Initial texture allocation / load image data (first load)
- (void)loadImageData:(GLTextureLoader)loader;
- (void)allocateStorage; // allocates on GPU (does it for 6 faces on cube maps). updateImageData can be used after this method has been invoked.

// ## Updating image data (after first load has been done)
- (void)updateImageData:(GLTextureUpdater)updater;

// ## Setting texture parameters
// General parameter setter (use empty masks to disable certain properties
- (void)setParameters:(GLTextureParameters)params;
// Useful parameter shortcuts:
// magnification / minification filters.
- (void)setMagFilter:(GLenum)magfil minFilter:(GLenum)mag;
// all dims, see setParameters: if more control is needed
- (void)setWrapMode:(GLenum)wraps;


// ## Mipmapping
- (void)generateMipmapLevels;

// ## Binding
- (void)bind;
- (void)unbind;
+ (void)unbind:(GLenum)target;

@end
