// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <Graphics/GteRasterizerState.h>
using namespace gte;


RasterizerState::RasterizerState()
    :
    fillMode(FILL_SOLID),
    cullMode(CULL_BACK),
    frontCCW(true),
    depthBias(0),
    depthBiasClamp(0.0f),
    slopeScaledDepthBias(0.0f),
    enableDepthClip(true),
    enableScissor(false),
    enableMultisample(false),
    enableAntialiasedLine(false)
{
    mType = GT_RASTERIZER_STATE;
}

