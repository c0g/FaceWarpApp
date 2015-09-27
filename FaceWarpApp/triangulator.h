//
//  triangulator.h
//  FaceWarpApp
//
//  Created by Thomas Nickson on 26/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//
#include "PHI_C_Types.h"
#include <CoreGraphics/CoreGraphics.h>

#ifdef __cplusplus
extern "C" {
#endif
    PhiTriangle * unsafeTidyIndices(CGPoint * edgesLandMarks, int nEdges, int nFaces, int * nTris);
#ifdef __cplusplus
}
#endif