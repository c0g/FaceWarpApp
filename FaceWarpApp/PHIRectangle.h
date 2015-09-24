//
//  PHIRectangle.h
//  FaceWarpApp
//
//  Created by Thomas Nickson on 24/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#ifndef PHIRectangle_h
#define PHIRectangle_h

typedef struct {
    float left;
    float top;
    float right;
    float bottom;
} Rectangle;

@interface NSValue (Rectangle)
+(instancetype) valueWithRectangle:(Rectangle)value;
@property (readonly) Rectangle rectangleValue;
@end

#endif /* PHIRectangle_h */
