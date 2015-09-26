//
//  normalise_warp.hpp
//  FaceWarpApp
//
//  Created by Thomas Gunter on 9/25/15.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#ifndef normalise_warp_h
#define normalise_warp_h

#ifdef __cplusplus
extern "C" {
#endif
    
double * return_adjusted_warp(double * landmarks, double * face_flat_warp);
    
#ifdef __cplusplus
}
#endif
#endif /* normalise_warp_h */
