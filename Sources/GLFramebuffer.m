//
//  GLFramebuffer.m
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import "GLFramebuffer.h"
#import "GLRenderbuffer.h"
#import "GLTexture.h"


@implementation GLFramebuffer

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
		mAttachments = [NSMutableDictionary new];
    }
    
    return self;
}


+ (GLFramebuffer*)framebuffer
{
	return [[self alloc] init];
}

#pragma mark -
#pragma mark Handle creation/destruction
- (void)createHandle
{
	GL_EXCEPT(mHandle, @"Trying to create a new handle over an existing one");
	
	glGenFramebuffers(1, &mHandle);
	
	GL_EXCEPT(!mHandle, @"Could not create handle (no current GL context?)"); 
}
- (void)destroyHandle
{
	GL_EXCEPT(mHandle != 0 && mHandleOwner != nil, @"Cannot destroy a handle if lifetime is managed by an owner");
	GL_EXCEPT(!mHandle, @"Trying to destroy a NULL handle");
	
	glDeleteFramebuffers(1, &mHandle);
	mHandle = 0;
}

#pragma mark -
#pragma mark Attachments
- (void)attachRenderBuffer:(GLRenderbuffer*)rbuffer toPoint:(GLenum)attachmentPoint
{
	GL_EXCEPT(rbuffer == nil, NSInvalidArgumentException);
	GL_EXCEPT(rbuffer.handle == 0, NSInvalidArgumentException);
	GL_EXCEPT([mAttachments objectForKey:[NSNumber numberWithLong:attachmentPoint]],
			  @"Existing attachment");

	if(mHandle == 0) 
		[self createHandle];
	[mAttachments setObject:rbuffer forKey:[NSNumber numberWithLong:attachmentPoint]];
	
	glBindFramebuffer(GL_FRAMEBUFFER, mHandle);
	//glBindRenderbuffer(GL_RENDERBUFFER, rbuffer.handle);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, attachmentPoint, GL_RENDERBUFFER, rbuffer.handle);
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}
- (void)attachTexture:(GLTexture*)texture toPoint:(GLenum)attachmentPoint target:(GLenum)textureTarget level:(GLint)level
{
	GL_EXCEPT(texture == nil, NSInvalidArgumentException);
	GL_EXCEPT(texture.handle == 0, NSInvalidArgumentException);
	GL_EXCEPT([mAttachments objectForKey:[NSNumber numberWithLong:attachmentPoint]],
			  @"Existing attachment");
	
	if(mHandle == 0) 
		[self createHandle];
	[mAttachments setObject:texture forKey:[NSNumber numberWithLong:attachmentPoint]];
	
	glBindFramebuffer(GL_FRAMEBUFFER, mHandle);
	//glBindRenderbuffer(GL_RENDERBUFFER, rbuffer.handle);
	glFramebufferTexture2D(GL_FRAMEBUFFER, attachmentPoint, textureTarget, texture.handle, level);
	glBindFramebuffer(GL_FRAMEBUFFER, 0);	
}
- (id)attachmentToPoint:(GLenum)attachmentPoint
{
	return [mAttachments objectForKey:[NSNumber numberWithLong:attachmentPoint]];
}
- (void)detach:(GLenum)attachmentPoint
{
	GL_EXCEPT(mHandle == 0, @"Receiver in invalid state");
	
	id attachment = [self attachmentToPoint:attachmentPoint];
	
	if(attachment == nil) 
	{
		GLLog(@"warning: no recorded attachment");
		return;
	}
	
	if([attachment isKindOfClass:[GLTexture class]])
	{
		glBindFramebuffer(GL_FRAMEBUFFER, mHandle);
		glFramebufferTexture2D(GL_FRAMEBUFFER, attachmentPoint, 0, 0, 0);
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		[mAttachments removeObjectForKey:[NSNumber numberWithLong:attachmentPoint]];
	}
	else if([attachment isKindOfClass:[GLRenderbuffer class]])
	{
		glBindFramebuffer(GL_FRAMEBUFFER, mHandle);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, attachmentPoint, GL_RENDERBUFFER, 0);
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		[mAttachments removeObjectForKey:[NSNumber numberWithLong:attachmentPoint]];
	}
}
- (void)discardAttachments:(NSArray*)attachments
{
#if TARGET_OS_IPHONE==1
	GLenum atts[attachments.count];
	for(int i=0; i<attachments.count; i++) atts[i] = [attachments[i] intValue];
	
	if([EAGLContext currentContext].API <= kEAGLRenderingAPIOpenGLES2)
		glDiscardFramebufferEXT(GL_FRAMEBUFFER, (GLsizei)attachments.count, atts);
	else
		glInvalidateFramebuffer(GL_FRAMEBUFFER, (GLsizei)attachments.count, atts);
#endif
}
- (GLenum)checkStatus
{
	GL_EXCEPT(mHandle == 0, NSInvalidArgumentException);
	
	glBindFramebuffer(GL_FRAMEBUFFER, mHandle);
	return glCheckFramebufferStatus(GL_FRAMEBUFFER);
}
- (BOOL)checkCompleteness
{
	return [self checkStatus] == GL_FRAMEBUFFER_COMPLETE;
}

- (void)bind
{
	GL_EXCEPT(mHandle == 0, @"Trying to bind non-existing buffer");
	glBindFramebuffer(GL_FRAMEBUFFER, mHandle);
}
+ (void)unbind
{
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}


@end
