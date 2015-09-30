//
//  normalise_warp.hpp
//  FaceWarpApp
//
//  Created by Thomas Gunter on 9/25/15.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#ifndef normalise_warp_h
#define normalise_warp_h

#include "PHI_C_Types.h"

#ifdef __cplusplus
extern "C" {
#endif
    
PhiPoint * adjusted_warp(PhiPoint * landmarks, PhiPoint * face_flat_warp, double * parameters);
    
PhiPoint * attractive_adjusted_warp(PhiPoint * landmarks, double * parameters);
    
PhiPoint * attractive_adjusted_warp2(PhiPoint * landmarks, double * parameters);
    
PhiPoint * silly_adjusted_warp(PhiPoint * landmarks, double * parameters);
    
#ifdef __cplusplus
}
#endif
#endif /* normalise_warp_h */
