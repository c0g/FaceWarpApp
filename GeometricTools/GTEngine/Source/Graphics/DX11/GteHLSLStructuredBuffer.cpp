// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <Graphics/DX11/GteHLSLStructuredBuffer.h>
using namespace gte;


HLSLStructuredBuffer::~HLSLStructuredBuffer()
{
}

HLSLStructuredBuffer::HLSLStructuredBuffer(
    D3D11_SHADER_INPUT_BIND_DESC const& desc)
    :
    HLSLResource(desc, 0)
{
    Initialize(desc);
}

HLSLStructuredBuffer::HLSLStructuredBuffer(
    D3D11_SHADER_INPUT_BIND_DESC const& desc, unsigned int index)
    :
    HLSLResource(desc, index, 0)
{
    Initialize(desc);
}

void HLSLStructuredBuffer::Initialize(
    D3D11_SHADER_INPUT_BIND_DESC const& desc)
{
    if (desc.Type == D3D_SIT_STRUCTURED
    ||  desc.Type == D3D_SIT_UAV_RWSTRUCTURED)
    {
        mType = SBT_BASIC;
    }
    else if (desc.Type == D3D_SIT_UAV_APPEND_STRUCTURED)
    {
        mType = SBT_APPEND;
    }
    else if (desc.Type == D3D_SIT_UAV_CONSUME_STRUCTURED)
    {
        mType = SBT_CONSUME;
    }
    else if (desc.Type == D3D_SIT_UAV_RWSTRUCTURED_WITH_COUNTER)
    {
        mType = SBT_COUNTER;
    }
    else
    {
        mType = SBT_INVALID;
    }

    mGpuWritable =
        desc.Type == D3D_SIT_UAV_RWSTRUCTURED ||
        desc.Type == D3D_SIT_UAV_APPEND_STRUCTURED ||
        desc.Type == D3D_SIT_UAV_CONSUME_STRUCTURED ||
        desc.Type == D3D_SIT_UAV_RWSTRUCTURED_WITH_COUNTER;
}

HLSLStructuredBuffer::Type HLSLStructuredBuffer::GetType() const
{
    return mType;
}

bool HLSLStructuredBuffer::IsGpuWritable() const
{
    return mGpuWritable;
}

