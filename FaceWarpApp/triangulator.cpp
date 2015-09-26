//
//  triangulator.cpp
//  FaceWarpApp
//
//  Created by Thomas Nickson on 26/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#import "triangulator.h"
#include <stdlib.h>

// Needs c linkage to be imported to Swift
extern "C" {
unsigned int * tidyIndices(int * edges, int nEdges, int * landMarks, int nFaces, int & nTris) {
    // CALLER TO FREE RETURN VALUE
    int numberOfPoints = 10;
    unsigned int  * results = (unsigned int *) malloc(numberOfPoints * sizeof(unsigned int));
    return results;
}
}