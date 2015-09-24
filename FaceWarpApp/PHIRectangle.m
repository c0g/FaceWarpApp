//
//  PHIRectangle.m
//  FaceWarpApp
//
//  Created by Thomas Nickson on 24/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHIRectangle.h"

@implementation NSValue (Rectangle)
+(instancetype)valueWithRectangle:(Rectangle)value {
    return [self valueWithBytes:&value objCType:@encode(Rectangle)];
}
- (Rectangle) rectangleValue {
    Rectangle value;
    [self getValue:&value];
    return value;
}
@end