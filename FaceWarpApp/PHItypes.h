//
//  PHIRectangle.h
//  FaceWarpApp
//
//  Created by Thomas Nickson on 24/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#ifndef PHITypes_h
#define PHITypes_h

#include "PHI_C_Points.h"

@interface NSValue (Rectangle)
+(instancetype) valueWithRectangle:(Rectangle)value;
@property (readonly) Rectangle rectangleValue;
@end

#endif /* PHIRectangle_h */
