//
//  PHIRectangle.m
//  FaceWarpApp
//
//  Created by Thomas Nickson on 24/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHItypes.h"

@implementation NSValue (PhiTriangle)
+(instancetype)valueWithTriangle:(PhiTriangle)value {
    return [self valueWithBytes:&value objCType:@encode(PhiTriangle)];
}
- (PhiTriangle) triangleValue {
    PhiTriangle value;
    [self getValue:&value];
    return value;
}
@end