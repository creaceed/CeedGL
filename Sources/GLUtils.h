//
//  GLUtils.h
//  CeedGL
//
//  Created by Raphael Sebbe on 19/08/15.
//  Copyright © 2015 Creaceed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLUtils : NSObject

+ (NSString*)rendererName;
+ (NSString*)vendorName;
+ (NSString*)versionString;

+ (NSString*)contextDescription;

@end
