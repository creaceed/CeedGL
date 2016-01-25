//
//  GLAllocator.m
//  CeedGL
//
//  Created by Raphael Sebbe on 22/01/15.
//  Copyright (c) 2015 Creaceed. All rights reserved.
//

#import <CeedGL/GLAllocator.h>
#import "GLObject+Internal.h"

@interface GLAllocator ()

@property (readonly) NSMutableSet *textures;
@property (readonly) NSMutableSet *buffers;
@property (readonly) NSMutableSet *shaders;
@property (readonly) NSMutableSet *programs;
@property (readonly) NSMutableSet *framebuffers;
@property (readonly) NSMutableSet *renderbuffers;

@end

@implementation GLAllocator

- (instancetype)init {
	self = [super init];
	if(self) {
		_textures = [NSMutableSet set];
		_buffers = [NSMutableSet set];
		_shaders = [NSMutableSet set];
		_programs = [NSMutableSet set];
		_framebuffers = [NSMutableSet set];
		_renderbuffers = [NSMutableSet set];
	}
	
	return self;
}

- (void)dealloc {
	
	NSSet *objects = self.allObjects;
	
	if(objects.count > 0)
		GLLogWarning(@"Allocator still contains GL objects while being deallocated. You should invoke -removeAllObjects under active GL context prior to deallocation.");
	
	// all handles should be destroyed by now. This code marks the objects that are still here that self is not the owner anymore.
	// this triggers a warning when those objects are deallocated if the handle is not 0. (so that we know there is a problem)
	// Note: we can't remove the remaining objects from here, as dealloc is typically not under the scope of an active CGLContext, hence the warning.
	for(GLObject *obj in self.allObjects) {
		obj.handleOwner = nil;
	}
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<GLAllocator: 0x%lx, name: %@>", (size_t)self, self.name];
}

- (GLAllocatorReference*)_ownerReference {
	GLAllocatorReference *ref = [[GLAllocatorReference alloc] init];
	
	ref.allocator = self;
	
	return ref;
}

- (id)_addNewObject:(GLObject*)object {
	NSMutableSet *set = [self _setForObject:object];
	
	GL_EXCEPT(set == nil, NSInvalidArgumentException);
	
	[object createHandle];
	object.handleOwner = [self _ownerReference];
	[set addObject:object];
	
	return object;
}

- (id)_addExistingObject:(GLObject*)object {
	NSMutableSet *set = [self _setForObject:object];
	
	GL_EXCEPT(set == nil, NSInvalidArgumentException);
	GL_EXCEPT(object.handle == 0, NSInvalidArgumentException);
	GL_EXCEPT(object.handleOwner != nil, NSInvalidArgumentException);
	
	object.handleOwner = [self _ownerReference];
	[set addObject:object];
	
	return object;
}

- (NSMutableSet*)_setForObject:(GLObject*)object {
	if([object isKindOfClass:GLTexture.class]) return self.textures;
	else if([object isKindOfClass:GLBuffer.class]) return self.buffers;
	else if([object isKindOfClass:GLShader.class]) return self.shaders;
	else if([object isKindOfClass:GLProgram.class]) return self.programs;
	else if([object isKindOfClass:GLFramebuffer.class]) return self.framebuffers;
	else if([object isKindOfClass:GLRenderbuffer.class]) return self.renderbuffers;
	else GL_EXCEPT(1, NSInvalidArgumentException);
	
	return nil;
}

- (GLTexture*)newTexture:(GLTextureSpecifier)spec { return [self _addNewObject:[GLTexture textureWithSpecifier:spec]]; }
- (GLBuffer*)newBuffer { return [self _addNewObject:[GLBuffer buffer]]; }
- (GLShader*)newVertexShader { return [self _addNewObject:[GLShader vertexShader]]; }
- (GLShader*)newFragmentShader { return [self _addNewObject:[GLShader fragmentShader]]; }
- (GLProgram*)newProgram { return [self _addNewObject:[GLProgram program]]; }
- (GLFramebuffer*)newFramebuffer { return [self _addNewObject:[GLFramebuffer framebuffer]]; }
- (GLRenderbuffer*)newRenderbuffer { return [self _addNewObject:[GLRenderbuffer renderbuffer]]; }


// Add pre-allocated objects, allocator takes over allocation manager (will dealloc it)
- (void)addObject:(GLObject*)object {
	[self _addExistingObject:object];
}

// Stops managing passed object, you become responsible for deallocating GL resources.
- (void)forgetObject:(GLObject*)object {
	NSMutableSet *set = [self _setForObject:object];
	
	GL_EXCEPT(set == nil, NSInternalInconsistencyException);
	GL_EXCEPT([set containsObject:object] == NO, NSInternalInconsistencyException);
	GL_EXCEPT(((GLAllocatorReference*)object.handleOwner).allocator != self, NSInternalInconsistencyException);
	GL_EXCEPT(object.handle == 0, NSInternalInconsistencyException);
	
	object.handleOwner = nil;
	[set removeObject:object];
}

- (NSArray*)_objectSets {
	return @[self.textures, self.buffers, self.shaders, self.programs, self.renderbuffers, self.framebuffers];
}
- (NSSet*)allObjects {
	NSSet *res = [NSSet set];
 
	for(NSSet *set in self._objectSets) {
		res = [res setByAddingObjectsFromSet:set];
	}
	return res;
}

// GL context must be set
- (void)_destroyObject:(GLObject*)object fromSet:(NSMutableSet*)set {
	GL_EXCEPT([set containsObject:object] == NO, NSInvalidArgumentException);
	GL_EXCEPT(((GLAllocatorReference*)object.handleOwner).allocator != self, NSInvalidArgumentException);
	GL_EXCEPT(object.handle == 0, NSInvalidArgumentException);
	
	object.handleOwner = nil;
	[object destroyHandle];
	[set removeObject:object];
}
- (void)destroyObject:(GLObject*)object {
	NSMutableSet *set = [self _setForObject:object];
	GL_EXCEPT(set == nil, NSInternalInconsistencyException);
	
	[self _destroyObject:object fromSet:set];
}
- (void)destroyAllObjects {
	for(NSMutableSet *set in self._objectSets) {
		for(GLObject *object in set.allObjects) {
			[self _destroyObject:object fromSet:set];
		}
	}
}

@end
