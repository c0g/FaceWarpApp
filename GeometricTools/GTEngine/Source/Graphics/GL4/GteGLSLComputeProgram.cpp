// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <Graphics/GL4/GteGLSLComputeProgram.h>
using namespace gte;


GLSLComputeProgram::~GLSLComputeProgram()
{
    if (glIsProgram(mProgramHandle))
    {
        if (glIsShader(mCShaderHandle))
        {
            glDetachShader(mProgramHandle, mCShaderHandle);
            glDeleteShader(mCShaderHandle);
        }

        glDeleteProgram(mProgramHandle);
    }
}

GLSLComputeProgram::GLSLComputeProgram(GLuint programHandle,
    GLuint cshaderHandle)
    :
    mProgramHandle(programHandle),
    mCShaderHandle(cshaderHandle),
    mReflector(programHandle)
{
}

