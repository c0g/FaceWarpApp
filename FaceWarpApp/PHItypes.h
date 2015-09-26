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

@interface NSValue (PhiRectangle)
+(instancetype) valueWithRectangle:(PhiRectangle)value;
@property (readonly) PhiRectangle rectangleValue;
@end

#endif /* PHITypes_h */
