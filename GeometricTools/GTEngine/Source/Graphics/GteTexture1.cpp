// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <Graphics/GteTexture1.h>
using namespace gte;


Texture1::Texture1(DFType format, unsigned int length, bool hasMipmaps,
    bool createStorage)
    :
    TextureSingle(format, 1, length, 1, 1, hasMipmaps, createStorage)
{
    mType = GT_TEXTURE1;
}

unsigned int Texture1::GetLength() const
{
    return TextureSingle::GetDimension(0);
}

