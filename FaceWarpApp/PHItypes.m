//
//  PHIRectangle.m
//  FaceWarpApp
//
//  Created by Thomas Nickson on 24/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHItypes.h"

@implementation NSValue (PhiRectangle)
+(instancetype)valueWithRectangle:(PhiRectangle)value {
    return [self valueWithBytes:&value objCType:@encode(PhiRectangle)];
}
- (PhiRectangle) rectangleValue {
    PhiRectangle value;
    [self getValue:&value];
    return value;
}
@end