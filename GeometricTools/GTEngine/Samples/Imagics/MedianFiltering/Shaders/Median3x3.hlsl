// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include "MedianShared.hlsli"

Texture2D<float> input;
RWTexture2D<float> output;

[numthreads(NUM_X_THREADS, NUM_Y_THREADS, 1)]
void CSMain(int2 dt : SV_DispatchThreadID)
{
    // Load the neighborhood of the pixel.  The use of float4 allows
    // vectorization in GetMinMaxN for speed.
    float4 e[NUM_ELEMENTS];  // 12 slots, we use the first 9
    LoadNeighbors(input, dt, e);

    // Repeated removal of minima and maxima.
    minmax6(e);         // Discard min and max of v0..v5 (2n+1=9, n+2=6).
    e[0].x = e[2].x;    // Copy v8 to v0 slot.
    minmax5(e);         // Discard min and max of v0..v4 (2n+1=7, n+2=5).
    e[0].x = e[1].w;    // Copy v7 to v0 slot.
    minmax4(e);         // Discard min and max of v0..v3 (2n+1=5, n+2=4).
    e[0].x = e[1].z;    // Copy v6 to v0 slot.
    minmax3(e);         // Sort v0, v1, and v2.

    // Return the median v1.
    output[dt] = e[0].y;
}
