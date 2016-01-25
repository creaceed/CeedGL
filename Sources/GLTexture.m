//
//  GLTexture.m
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <CeedGL/GLTexture.h>
#import "GLObject+Internal.h"


BOOL GLTextureKindIsArray(GLTextureKind type) {
	return type == GLTextureKind1DArray || type == GLTextureKind2DArray;
}
int GLTextureKindGetDimension(GLTextureKind type) {
	switch (type) {
		case GLTextureKind1D:
		case GLTextureKind1DArray:
			return 1;
		case GLTextureKind2D:
		case GLTextureKind2DArray:
		case GLTextureKindCubemap:
			return 2;
		case GLTextureKind3D:
			return 3;
	}
}

GLTextureSpecifier GLTextureSpecifierMakeEmpty(void) {
	GLTextureSpecifier spec = {0};
	
	return spec;
}

GLTextureSpecifier GLTextureSpecifierMakeTexture2D(GLenum  target, GLsizei w, GLsizei h, GLenum format, GLenum type) {
	GLTextureSpecifier spec = GLTextureSpecifierMakeEmpty();
	
	spec.kind = GLTextureKind2D;
	spec.target = target;
	spec.width = w;
	spec.height = h;
	spec.depth = 1;
	spec.format = format;
	spec.type = type;
	spec.arrayLength = 0;
	spec.border = 0;
	
	return spec;
}

GLTextureSpecifier GLTextureSpecifierMakeTexture3D(GLenum  target, GLsizei w, GLsizei h, GLsizei d, GLenum format, GLenum type) {
	GLTextureSpecifier spec = GLTextureSpecifierMakeEmpty();
	
	spec.kind = GLTextureKind3D;
	spec.target = target;
	spec.width = w;
	spec.height = h;
	spec.depth = d;
	spec.format = format;
	spec.type = type;
	spec.arrayLength = 0;
	spec.border = 0;
	
	return spec;
}
GLTextureLoader GLTextureLoaderMakeEmpty(void) {
	GLTextureLoader res = {0};
	
	return res;
}
GLTextureLoader GLTextureLoaderMakeNativeData(void *data) {
	GLTextureLoader res = GLTextureLoaderMakeEmpty();
	
	res.source = GLTextureImageSourceData;
	res.data.bytes = data;
	
	// 0 -> use native
	res.data.format = 0;
	res.data.type = 0;
	
	return res;
}

GLTextureUpdater GLTextureUpdaterMakeEmpty(void) {
	GLTextureUpdater res = {0};
	
	return res;
}
GLTextureUpdater GLTextureUpdaterMakeData2D(void *data, GLint xoff, GLint yoff, GLsizei width, GLsizei height) {
	GLTextureUpdater res = GLTextureUpdaterMakeEmpty();
	
	res.source = GLTextureImageSourceData;
	res.data.format = 0;
	res.data.type = 0;
	res.data.bytes = data;
	
	res.range.x = xoff;
	res.range.y = yoff;
	res.range.z = 0;

	res.range.width = width;
	res.range.height = height;
	res.range.depth = 1;
	
	return res;
}
GLTextureUpdater GLTextureUpdaterMakeData3D(void *data, GLint xoff, GLint yoff, GLint zoff, GLsizei width, GLsizei height, GLsizei depth) {
	GLTextureUpdater res = GLTextureUpdaterMakeEmpty();
	
	res.source = GLTextureImageSourceData;
	res.data.format = 0;
	res.data.type = 0;
	res.data.bytes = data;
	
	res.range.x = xoff;
	res.range.y = yoff;
	res.range.z = zoff;
	
	res.range.width = width;
	res.range.height = height;
	res.range.depth = depth;
	
	return res;
}

GLTextureParameters GLTextureParametersMakeEmpty(void) {
	GLTextureParameters params = {0};
	return params;
}
void GLTextureParametersSetFilter(GLTextureParameters *params, GLenum minFilter, GLenum magFilter) {
	params->filter.min = minFilter;
	params->filter.mag = magFilter;
	params->filter.mask = GLTextureFilterMaskMinification | GLTextureFilterMaskMagnification;
}

void GLTextureParametersSetWrapMode2D(GLTextureParameters *params, GLenum s, GLenum t) {
	params->wrapMode.s = s;
	params->wrapMode.t = t;
	params->wrapMode.mask = GLTextureWrapModeMaskS;
}
void GLTextureParametersSetWrapMode3D(GLTextureParameters *params, GLenum s, GLenum t, GLenum r) {
	params->wrapMode.s = s;
	params->wrapMode.t = t;
	params->wrapMode.r = r;
	params->wrapMode.mask = GLTextureWrapModeMaskS | GLTextureWrapModeMaskT | GLTextureWrapModeMaskR;
}

@implementation GLTexture

//@synthesize width = mWidth, height = mHeight, format = mFormat,  border = mBorder, type = mType, target = mTarget;

- (id)init {
	//GL_EXCEPT(1, @"Texture must be specified on creation");
	GLLogWarning(@"Creating texture without specifier is deprecated.");
	
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

+ (instancetype)texture
{
	return [[self alloc] init];
}

- (NSString*)_sizeString {
	NSString *res = nil;
	switch (self.kind) {
		case GLTextureKind1D:
		case GLTextureKind1DArray:
			res = [NSString stringWithFormat:@"%d", self.width];
			break;
		case GLTextureKind2D:
		case GLTextureKind2DArray:
			res = [NSString stringWithFormat:@"%dx%d", self.width, self.height];
			break;
		case GLTextureKindCubemap:
			res = [NSString stringWithFormat:@"%d", self.width];
			break;
		case GLTextureKind3D:
			res = [NSString stringWithFormat:@"%dx%dx%d", self.width, self.height, self.depth];
			break;
		default:
			break;
	}
	
	return res;
}

- (NSString*)_typeString {
	switch (self.kind) {
		case GLTextureKind1D: return @"Texture 1D";
		case GLTextureKind1DArray: return @"Texture 1D Array";
		case GLTextureKind2D: return @"Texture 2D";
		case GLTextureKind2DArray: return @"Texture 2D Array";
		case GLTextureKindCubemap: return @"Texture Cubemap";
		case GLTextureKind3D: return @"Texture 3D";
	}
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<GLTexture [%@]: 0x%lx, size: %@, handle: %d, format/type: 0x%x/0x%x, owner: %@>", self._typeString, (size_t)self, self._sizeString, self.handle, self.format, self.type, [self _ownerDescription]];
}

#pragma mark - Overrides -

- (void)createHandle
{
	GL_EXCEPT(mHandle, @"Trying to create a new handle over an existing one");
	
	glGenTextures(1, &mHandle);
	
	GL_EXCEPT(!mHandle, @"Could not create handle (no current GL context?)"); 
}

- (void)destroyHandle
{
	GL_EXCEPT(mHandle != 0 && mHandleOwner != nil, @"Cannot destroy a handle if lifetime is managed by an owner");
	GL_EXCEPT(!mHandle, @"Trying to destroy a NULL handle");
	
	glDeleteTextures(1, &mHandle);
	mHandle = 0;
}

#pragma mark - Texture API -

+ (void)_checkSpecifier:(GLTextureSpecifier)spec {
	GL_EXCEPT(spec.target == 0, @"Target cannot be 0.");
	GL_EXCEPT(spec.width == 0, @"Width cannot be 0.");
	GL_EXCEPT(spec.type == 0, @"Type cannot be 0.");
	GL_EXCEPT(spec.format == 0, @"Format cannot be 0.");
	GL_EXCEPT(spec.arrayLength > 0 && !GLTextureKindIsArray(spec.kind), @"arrayLength should only be provided for array types.");
	GL_EXCEPT(spec.depth != 1 && GLTextureKindGetDimension(spec.kind) != 3, @"depth parameter should be 1 for non-3D textures.");
}

- (void)_setSpecifier:(GLTextureSpecifier)spec {
	GL_EXCEPT(self.target != 0, @"Texture is already specified.");
	
	[GLTexture _checkSpecifier:spec];
	
	_kind = spec.kind;
	_format = spec.format;
	_target = spec.target;
	_width = spec.width;
	_height = spec.height;
	_depth = spec.depth;
	_border = spec.border;
	_type = spec.type;
	_arrayLength = spec.arrayLength;
}

- (void)_checkSpecified {
	GL_EXCEPT(self.target == 0, @"Texture should be specified");
}

- (instancetype)initWithSpecifier:(GLTextureSpecifier)s {
	self = [super init];
	if(self == nil) return nil;
	
	[self _setSpecifier:s];
	
	return self;
}

+ (instancetype)textureWithSpecifier:(GLTextureSpecifier)s {
	return [[self alloc] initWithSpecifier:s];
}

// ## Set texture handle from pre-created texture
- (void)setFromExistingHandle:(GLint)handle {
	[self _checkSpecified];
	mHandle = handle;
}

- (BOOL)_isPOT {
	return ((_width & (_width- 1)) == 0) && ((_height & (_height - 1)) == 0) && ((_depth & (_depth - 1)) == 0);
}

- (void)_setAlignmentForTextureData:(GLTextureData*)data {
	GLint alignment = data->alignment;
	
	if(alignment == -1) return;
	if(alignment == 0) alignment = 4;
	
	glPixelStorei(GL_UNPACK_ALIGNMENT, alignment);
}

// ## Load image data (first load)
- (void)loadImageData:(GLTextureLoader)loader {
	[self _checkSpecified];
	
	BOOL npot = ![self _isPOT];
	if(mHandle == 0)
		[self createHandle];
	
	[self bind];

	// Setting required parameters (to avoid incomplete texture)
	int dim = GLTextureKindGetDimension(_kind);
	GLTextureParameters params = GLTextureParametersMakeEmpty();
	
	params.filter.min = GL_NEAREST;
	params.filter.mag = GL_NEAREST;
	params.filter.mask = GLTextureFilterMaskAll;
	
	params.wrapMode.s = GL_CLAMP_TO_EDGE;
	params.wrapMode.t = GL_CLAMP_TO_EDGE;
	params.wrapMode.r = GL_CLAMP_TO_EDGE;
	params.wrapMode.mask = GLTextureWrapModeMaskS | (dim>=2?GLTextureWrapModeMaskT:0) | (dim>=3?GLTextureWrapModeMaskR:0);
	
	if(loader.data.format == 0) loader.data.format = _format;
	if(loader.data.type == 0) loader.data.type = _type;
	
	if(npot &&
	   (params.wrapMode.s != GL_CLAMP_TO_EDGE || params.wrapMode.t != GL_CLAMP_TO_EDGE)) {
		GLLogWarning(@"NPOT textures require clamp to edge");
	}
	
	[self _setParameters:params skipBind:YES];

	if(loader.source == GLTextureImageSourceData)
		[self _setAlignmentForTextureData:&loader.data];
	
	switch (_kind) {
		case GLTextureKind2D:
			switch (loader.source) {
				case GLTextureImageSourceAllocateOnly:
					glTexImage2D(_target, loader.mipmapLevel, _format, _width, _height, _border, _format, _type, NULL);
					break;
				case  GLTextureImageSourceData:
#if TARGET_OS_IPHONE
					GL_EXCEPT(loader.data.type != _type, @"Type must match with GLES");
#endif
					glTexImage2D(_target, loader.mipmapLevel, _format, _width, _height, _border, loader.data.format, loader.data.type, loader.data.bytes);
					break;
				case  GLTextureImageSourceFramebuffer:
					glCopyTexImage2D(_target, loader.mipmapLevel, _format, loader.framebuffer.x, loader.framebuffer.y, _width, _height, _border);
					break;
				default:
					GL_EXCEPT_NOTIMPLEMENTED();
					
			}
			break;
		case GLTextureKind3D:
#if USE_GLES3 || GL_MAC
			switch (loader.source) {
					
				case GLTextureImageSourceAllocateOnly:
					glTexImage3D(_target, loader.mipmapLevel, _format, _width, _height, _depth, _border, _format, _type, NULL);
					break;
					
				case  GLTextureImageSourceData:
#if TARGET_OS_IPHONE
					GL_EXCEPT(loader.data.type != _type, @"Type must match with GLES");
#endif
					glTexImage3D(_target, loader.mipmapLevel, _format, _width, _height, _depth, _border, loader.data.format, loader.data.type, loader.data.bytes);
					break;
				default:
					GL_EXCEPT_NOTIMPLEMENTED();
			}
			break;
#endif
		default:
			GL_EXCEPT_NOTIMPLEMENTED();
	}
	
	GLCheckError();
}
- (void)allocateStorage {
	GLTextureLoader loader = {0};
	
	loader.source = GLTextureImageSourceAllocateOnly;
	loader.mipmapLevel = 0;
	
	[self loadImageData:loader];
}

// ## Update image data (after first load has been done)
- (void)updateImageData:(GLTextureUpdater)updater {
	[self bind];
	GLCheckError();
	
	if(updater.data.format == 0) updater.data.format = _format;
	if(updater.data.type == 0) updater.data.type = _type;
	
	if(updater.source == GLTextureImageSourceData)
		[self _setAlignmentForTextureData:&updater.data];
	
	switch(_kind) {
		case GLTextureKind2D:
			glTexSubImage2D(_target, updater.mipmapLevel, updater.range.x, updater.range.y, updater.range.width, updater.range.height, updater.data.format, updater.data.type, updater.data.bytes);
			break;
		default:
			GL_EXCEPT_NOTIMPLEMENTED();
	}
	
	GLCheckError();
}

- (void)setMagFilter:(GLenum)magfil minFilter:(GLenum)minfil {
	GLTextureParameters params = GLTextureParametersMakeEmpty();
	
	params.filter.mag = magfil;
	params.filter.min = minfil;
	params.filter.mask = GLTextureFilterMaskMagnification | GLTextureFilterMaskMinification;
	
	[self setParameters:params];
}

// Setting texture parameters
- (void)setWrapMode:(GLenum)wrap {
	GLTextureParameters params = GLTextureParametersMakeEmpty();
	int dim = GLTextureKindGetDimension(_kind);
	
	params.wrapMode.s = wrap;
	params.wrapMode.t = wrap;
	params.wrapMode.r = wrap;
	params.wrapMode.mask = GLTextureWrapModeMaskS | (dim>=2?GLTextureWrapModeMaskT:0) | (dim>=3?GLTextureWrapModeMaskR:0);
	
	[self setParameters:params];
}
// General parameter setter (use empty masks to disable certain properties
- (void)_setParameters:(GLTextureParameters)params skipBind:(BOOL)sb {
	if(!sb) [self bind];
	
	//	int align = 1;
	//	glPixelStorei(GL_UNPACK_ALIGNMENT, align);
	if(params.wrapMode.mask & GLTextureWrapModeMaskS)
		glTexParameteri(_target, GL_TEXTURE_WRAP_S, params.wrapMode.s);
	if(params.wrapMode.mask & GLTextureWrapModeMaskT)
		glTexParameteri(_target, GL_TEXTURE_WRAP_T, params.wrapMode.t);

#if USE_GLES3 || GL_MAC
	if(params.wrapMode.mask & GLTextureWrapModeMaskR)
		glTexParameteri(_target, GL_TEXTURE_WRAP_R, params.wrapMode.r);
#endif
	if(params.filter.mask & GLTextureFilterMaskMinification)
		glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, params.filter.min);
	if(params.filter.mask & GLTextureFilterMaskMagnification)
		glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, params.filter.mag);
	
	GLCheckError();
}

- (void)setParameters:(GLTextureParameters)params {
	[self _setParameters:params skipBind:NO];
}


- (void)generateMipmapLevels {
	GL_EXCEPT(mHandle == 0, @"Trying to generate mipmap on empty texture");
	
	[self bind];
#if USE_CORE_PROFILE_32 || TARGET_OS_IPHONE
	glGenerateMipmap(_target);
#else
	glGenerateMipmapEXT(_target);
#endif
	[self unbind];
	
	// this was required on legacy context (Mac) in my testing, not too sure for other cases.
	glFlush();
}

- (void)bind
{
	GL_EXCEPT(mHandle == 0, @"Trying to bind non-existing buffer");
	GL_EXCEPT(_target == 0, @"Target not yet determined");
	// should not be passed in modern profile OpenGL. Only for fixed-function pipeline, which we don't handle.
//	glEnable(GL_TEXTURE_3D);
	glBindTexture(_target, mHandle);
	GLCheckError();
}
- (void)unbind {
	GL_EXCEPT(_target == 0, @"Target not yet determined");
	glBindTexture(_target, 0);
}
+ (void)unbind:(GLenum)target
{
	glBindTexture(target, 0);
}

#pragma mark -
#pragma mark Accessors
- (CGSize)size
{
	return CGSizeMake(_width, _height);
}

@end

