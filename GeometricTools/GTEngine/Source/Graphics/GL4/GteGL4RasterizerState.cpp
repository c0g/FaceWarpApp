// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <LowLevel/GteLogger.h>
#include <Graphics/GL4/GteGL4RasterizerState.h>
using namespace gte;


GL4RasterizerState::~GL4RasterizerState()
{
}

GL4RasterizerState::GL4RasterizerState(RasterizerState const* rasterizerState)
    :
    GL4DrawingState(rasterizerState)
{
    mFillMode = msFillMode[rasterizerState->fillMode];
    mCullFace = msCullFace[rasterizerState->cullMode];
    mFrontFace = (rasterizerState->frontCCW ? GL_CCW : GL_CW);
    mDepthScale = rasterizerState->slopeScaledDepthBias;
    mDepthBias = (float)rasterizerState->depthBias;
    mEnableScissor = (rasterizerState->enableScissor ? GL_TRUE : GL_FALSE);
}

GL4GraphicsObject* GL4RasterizerState::Create(GraphicsObject const* object)
{
    if (object->GetType() == GT_RASTERIZER_STATE)
    {
        return new GL4RasterizerState(
            static_cast<RasterizerState const*>(object));
    }

    LogError("Invalid object type.");
    return nullptr;
}

RasterizerState* GL4RasterizerState::GetRasterizerState()
{
    return static_cast<RasterizerState*>(mGTObject);
}

void GL4RasterizerState::Enable(HGLRC)
{
    glPolygonMode(GL_FRONT_AND_BACK, mFillMode);

    if (mCullFace != 0)
    {
        glEnable(GL_CULL_FACE);
        glFrontFace(mFrontFace);
        glCullFace(mCullFace);
    }
    else
    {
        glDisable(GL_CULL_FACE);
    }

    if (mDepthScale != 0.0f && mDepthBias != 0.0f)
    {
        glEnable(GL_POLYGON_OFFSET_FILL);
        glEnable(GL_POLYGON_OFFSET_LINE);
        glEnable(GL_POLYGON_OFFSET_POINT);
        glPolygonOffset(mDepthScale, mDepthBias);
    }
    else
    {
        glDisable(GL_POLYGON_OFFSET_FILL);
        glDisable(GL_POLYGON_OFFSET_LINE);
        glDisable(GL_POLYGON_OFFSET_POINT);
    }
}


GLenum const GL4RasterizerState::msFillMode[] =
{
    GL_FILL,
    GL_LINE
};

GLenum const GL4RasterizerState::msCullFace[] =
{
    0,
    GL_FRONT,
    GL_BACK
};
