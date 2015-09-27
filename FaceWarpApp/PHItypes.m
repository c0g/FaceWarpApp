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
+(instancetype)valueWithPhiTriangle:(PhiTriangle)value {
    return [self valueWithBytes:&value objCType:@encode(PhiTriangle)];
}
- (PhiTriangle) PhiTriangleValue {
    PhiTriangle value;
    [self getValue:&value];
    return value;
}
@end

@implementation NSValue (PhiPoint)
+(instancetype)valueWithPhiPoint:(PhiPoint)value {
    return [self valueWithBytes:&value objCType:@encode(PhiPoint)];
}
- (PhiPoint) PhiPointValue {
    PhiPoint value;
    [self getValue:&value];
    return value;
}
@end