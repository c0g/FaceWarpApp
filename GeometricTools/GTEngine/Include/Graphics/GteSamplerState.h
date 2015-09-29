// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Mathematics/GteVector4.h>
#include <Graphics/GteDrawingState.h>

namespace gte
{

class GTE_IMPEXP SamplerState : public DrawingState
{
public:
    // The encoding involves minification (MIN), magnification (MAG), and
    // mip-level filtering (MIP).  After each is P (POINT) or L (LINEAR).
    enum GTE_IMPEXP Filter
    {
        MIN_P_MAG_P_MIP_P,
        MIN_P_MAG_P_MIP_L,
        MIN_P_MAG_L_MIP_P,
        MIN_P_MAG_L_MIP_L,
        MIN_L_MAG_P_MIP_P,
        MIN_L_MAG_P_MIP_L,
        MIN_L_MAG_L_MIP_P,
        MIN_L_MAG_L_MIP_L,
        ANISOTROPIC,
        COMPARISON_MIN_P_MAG_P_MIP_P,
        COMPARISON_MIN_P_MAG_P_MIP_L,
        COMPARISON_MIN_P_MAG_L_MIP_P,
        COMPARISON_MIN_P_MAG_L_MIP_L,
        COMPARISON_MIN_L_MAG_P_MIP_P,
        COMPARISON_MIN_L_MAG_P_MIP_L,
        COMPARISON_MIN_L_MAG_L_MIP_P,
        COMPARISON_MIN_L_MAG_L_MIP_L,
        COMPARISON_ANISOTROPIC
    };

    // Modes for handling texture coordinates at texture-image boundaries.
    enum GTE_IMPEXP Mode
    {
        WRAP,
        MIRROR,
        CLAMP,
        BORDER,
        MIRROR_ONCE
    };

    enum GTE_IMPEXP Comparison
    {
        NEVER,
        LESS,
        EQUAL,
        LESS_EQUAL,
        GREATER,
        NOT_EQUAL,
        GREATER_EQUAL,
        ALWAYS
    };

    // Construction.
    SamplerState();

    // Member access.  The members are intended to be write-once before
    // you create an associated graphics state.
    Filter filter;
    Mode mode[3];
    float mipLODBias;
    unsigned int maxAnisotropy;
    Comparison comparison;
    Vector4<float> borderColor;
    float minLOD;
    float maxLOD;

public:
    // For use by the Shader class for storing reflection information.
    static int const shaderDataLookup = 6;
};

}
