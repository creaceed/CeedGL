//
//  GLTexture+GLKit.h
//  CeedGL
//
//  Created by Raphael Sebbe on 28/07/15.
//  Copyright © 2015 Creaceed. All rights reserved.
//

#import <CeedGL/GLTexture.h>

@interface GLTexture (GLKit)

+ (GLTextureSpecifier)textureSpecifierFromTextureInfo:(GLKTextureInfo*)info;
+ (instancetype)textureWithFileAtURL:(NSURL*)url options:(NSDictionary*)options error:(NSError **)perror;

@end
