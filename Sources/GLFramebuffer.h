//
//  GLFramebuffer.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CeedGL/GLObject.h>

@class GLTexture, GLRenderbuffer;

@interface GLFramebuffer : GLObject {
	
	NSMutableDictionary	*mAttachments;
}

+ (GLFramebuffer*)framebuffer;

// Attachments
- (void)attachRenderBuffer:(GLRenderbuffer*)rbuffer toPoint:(GLenum)attachmentPoint;
- (void)attachTexture:(GLTexture*)texture toPoint:(GLenum)attachmentPoint target:(GLenum)textureTarget level:(GLint)level;
- (id)attachmentToPoint:(GLenum)attpoint;
- (void)detach:(GLenum)attachmentPoint;
- (void)discardAttachments:(NSArray*)attachements; // iOS-only
- (GLenum)checkStatus;
- (BOOL)checkCompleteness;


// Binding
- (void)bind;
+ (void)unbind;

@end
