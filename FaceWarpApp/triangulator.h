//
//  triangulator.h
//  FaceWarpApp
//
//  Created by Thomas Nickson on 26/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//
#ifdef __cplusplus
extern "C" {
#endif
    int * tidyIndices(int * edges, int nEdges, int * landMarks, int nFaces, int * nTris);
#ifdef __cplusplus
}
#endif