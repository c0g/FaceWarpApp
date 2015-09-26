//
//  triangulator.h
//  FaceWarpApp
//
//  Created by Thomas Nickson on 26/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//
#include "PHI_C_Types.h"

#ifdef __cplusplus
extern "C" {
#endif
    triangle * tidyIndices(point * edgesLandMarks, int nEdges, int nFaces, int * nTris);
#ifdef __cplusplus
}
#endif