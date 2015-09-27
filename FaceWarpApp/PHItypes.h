//
//  PHIRectangle.h
//  FaceWarpApp
//
//  Created by Thomas Nickson on 24/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#ifndef PHITypes_h
#define PHITypes_h

#include "PHI_C_Types.h"

@interface NSValue (PhiTriangle)
+(instancetype) valueWithTriangle:(PhiTriangle)value;
@property (readonly) PhiTriangle triangleValue;
@end

#endif /* PHITypes_h */
