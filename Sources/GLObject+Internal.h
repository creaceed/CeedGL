//
//  GLObject+Internal.h
//  CeedGL
//
//  Created by Raphael Sebbe on 23/01/15.
//  Copyright (c) 2015 Creaceed. All rights reserved.
//

#import <CeedGL/CeedGL.h>

@interface GLObject ()

- (NSString*)_ownerDescription;

@end


@class GLAllocator;
@interface GLAllocatorReference : NSObject

@property (weak) GLAllocator *allocator;

@end