// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <LowLevel/GteLogger.h>
#include <Graphics/GL4/GteGL4IndexBuffer.h>
using namespace gte;


GL4IndexBuffer::~GL4IndexBuffer()
{
    glDeleteBuffers(1, &mGLHandle);
}

GL4IndexBuffer::GL4IndexBuffer(IndexBuffer const* ibuffer)
    :
    GL4Buffer(ibuffer, GL_ELEMENT_ARRAY_BUFFER)
{
}

GL4GraphicsObject* GL4IndexBuffer::Create(GraphicsObject const* object)
{
    if (object->GetType() == GT_INDEX_BUFFER)
    {
        return new GL4IndexBuffer(static_cast<IndexBuffer const*>(object));
    }

    LogError("Invalid object type.");
    return nullptr;
}

void GL4IndexBuffer::Enable()
{
    glBindBuffer(mType, mGLHandle);
}

void GL4IndexBuffer::Disable()
{
    glBindBuffer(mType, 0);
}

