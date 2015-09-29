// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Graphics/GteTexture2.h>

namespace gte
{

class GTE_IMPEXP TextureDS : public Texture2
{
public:
    // Construction for depth-stencil textures.
    TextureDS(DFType format, unsigned int width, unsigned int height,
        bool createStorage = true);
};

}
