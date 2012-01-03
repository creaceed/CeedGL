//
//  GLBufferDataSource.h
//  CeedGL
//
//  Created by Raphael Sebbe on 01/11/10.
//  Copyright (c) 2010 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GLBufferDataSource <NSObject>

- (const GLvoid*)bufferData;
- (GLsizeiptr)bufferDataSize;

@end
