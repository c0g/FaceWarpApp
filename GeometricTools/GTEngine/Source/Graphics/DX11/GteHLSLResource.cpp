// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <Graphics/DX11/GteHLSLResource.h>
using namespace gte;


HLSLResource::~HLSLResource()
{
}

HLSLResource::HLSLResource(D3D11_SHADER_INPUT_BIND_DESC const& desc,
    unsigned int numBytes)
    :
    mNumBytes(numBytes)
{
    mDesc.name = std::string(desc.Name);
    mDesc.bindPoint = desc.BindPoint;
    mDesc.bindCount = desc.BindCount;
    mDesc.type = desc.Type;
    mDesc.flags = desc.uFlags;
    mDesc.returnType = desc.ReturnType;
    mDesc.dimension = desc.Dimension;
    mDesc.numSamples = desc.NumSamples;
}

HLSLResource::HLSLResource(D3D11_SHADER_INPUT_BIND_DESC const& desc,
    unsigned int index, unsigned int numBytes)
    :
    mNumBytes(numBytes)
{
    mDesc.name = std::string(desc.Name) + "[" + std::to_string(index) + "]";
    mDesc.bindPoint = desc.BindPoint + index;
    mDesc.bindCount = 1;
    mDesc.type = desc.Type;
    mDesc.flags = desc.uFlags;
    mDesc.returnType = desc.ReturnType;
    mDesc.dimension = desc.Dimension;
    mDesc.numSamples = desc.NumSamples;
}

std::string const& HLSLResource::GetName() const
{
    return mDesc.name;
}

D3D_SHADER_INPUT_TYPE HLSLResource::GetType() const
{
    return mDesc.type;
}

unsigned int HLSLResource::GetBindPoint() const
{
    return mDesc.bindPoint;
}

unsigned int HLSLResource::GetBindCount() const
{
    return mDesc.bindCount;
}

unsigned int HLSLResource::GetFlags() const
{
    return mDesc.flags;
}

D3D_RESOURCE_RETURN_TYPE HLSLResource::GetReturnType() const
{
    return mDesc.returnType;
}

D3D_SRV_DIMENSION HLSLResource::GetDimension() const
{
    return mDesc.dimension;
}

unsigned int HLSLResource::GetNumSamples() const
{
    return mDesc.numSamples;
}

unsigned int HLSLResource::GetNumBytes() const
{
    return mNumBytes;
}

void HLSLResource::Print(std::ofstream& output) const
{
    output << "name = " << mDesc.name << std::endl;
    output << "shader input type = " << msSIType[mDesc.type] << std::endl;
    output << "bind point = " << mDesc.bindPoint << std::endl;
    output << "bind count = " << mDesc.bindCount << std::endl;
    output << "flags = " << mDesc.flags << std::endl;
    output << "return type = " << msReturnType[mDesc.returnType] << std::endl;
    output << "dimension = " << msSRVDimension[mDesc.dimension] << std::endl;
    if (mDesc.numSamples == 0xFFFFFFFFu)
    {
        output << "samples = -1" << std::endl;
    }
    else
    {
        output << "samples = " << mDesc.numSamples << std::endl;
    }
    output << "number of bytes = " << mNumBytes << std::endl;
}


std::string const HLSLResource::msSIType[]
{
    "D3D_SIT_CBUFFER",
    "D3D_SIT_TBUFFER",
    "D3D_SIT_TEXTURE",
    "D3D_SIT_SAMPLER",
    "D3D_SIT_UAV_RWTYPED",
    "D3D_SIT_STRUCTURED",
    "D3D_SIT_UAV_RWSTRUCTURED",
    "D3D_SIT_BYTEADDRESS",
    "D3D_SIT_UAV_RWBYTEADDRESS",
    "D3D_SIT_UAV_APPEND_STRUCTURED",
    "D3D_SIT_UAV_CONSUME_STRUCTURED",
    "D3D_SIT_UAV_RWSTRUCTURED_WITH_COUNTER"
};

std::string const HLSLResource::msReturnType[] =
{
    "none",  // There is no D3D_RESOURCE_RETURN_TYPE for value 0.
    "D3D_RETURN_TYPE_UNORM",
    "D3D_RETURN_TYPE_SNORM",
    "D3D_RETURN_TYPE_SINT",
    "D3D_RETURN_TYPE_UINT",
    "D3D_RETURN_TYPE_FLOAT",
    "D3D_RETURN_TYPE_MIXED",
    "D3D_RETURN_TYPE_DOUBLE",
    "D3D_RETURN_TYPE_CONTINUED"
};

std::string const HLSLResource::msSRVDimension[] =
{
    "D3D_SRV_DIMENSION_UNKNOWN",
    "D3D_SRV_DIMENSION_BUFFER",
    "D3D_SRV_DIMENSION_TEXTURE1D",
    "D3D_SRV_DIMENSION_TEXTURE1DARRAY",
    "D3D_SRV_DIMENSION_TEXTURE2D",
    "D3D_SRV_DIMENSION_TEXTURE2DARRAY",
    "D3D_SRV_DIMENSION_TEXTURE2DMS",
    "D3D_SRV_DIMENSION_TEXTURE2DMSARRAY",
    "D3D_SRV_DIMENSION_TEXTURE3D",
    "D3D_SRV_DIMENSION_TEXTURECUBE",
    "D3D_SRV_DIMENSION_TEXTURECUBEARRAY",
    "D3D_SRV_DIMENSION_BUFFEREX"
};
