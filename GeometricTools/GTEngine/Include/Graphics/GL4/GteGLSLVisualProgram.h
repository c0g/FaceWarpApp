// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Graphics/GteVisualProgram.h>
#include <Graphics/GL4/GteGLSLReflection.h>

// TODO: Move GLSLReflection out of the class.  The reflection work should
// be done in GLSLProgramFactory, GTEngine-required data packaged in the
// factory, and this graphics-API-independent data passed to the Shader
// constructors.  HLSL factory creation should do the same so that Shader
// does not know about graphics API.  We also don't want VisualProgram-derived
// classes storing so much information that is not used.

namespace gte
{

class GTE_IMPEXP GLSLVisualProgram : public VisualProgram
{
public:
    // Construction and destruction.
    virtual ~GLSLVisualProgram();
    GLSLVisualProgram(GLuint programHandle, GLuint vshaderHandle,
        GLuint pshaderHandle, GLuint gshaderHandle);

    // Member access.  GLEngine needs the program handle for enabling and
    // disabling the program.  TODO: Do we need the Get*ShaderHandle
    // functions?
    inline GLuint GetProgramHandle() const;
    inline GLuint GetVShaderHandle() const;
    inline GLuint GetPShaderHandle() const;
    inline GLuint GetGShaderHandle() const;
    inline GLSLReflection const& GetReflector() const;

private:
    GLuint mProgramHandle, mVShaderHandle, mPShaderHandle, mGShaderHandle;
    GLSLReflection mReflector;
};


inline GLuint GLSLVisualProgram::GetProgramHandle() const
{
    return mProgramHandle;
}

inline GLuint GLSLVisualProgram::GetVShaderHandle() const
{
    return mVShaderHandle;
}

inline GLuint GLSLVisualProgram::GetPShaderHandle() const
{
    return mPShaderHandle;
}

inline GLuint GLSLVisualProgram::GetGShaderHandle() const
{
    return mGShaderHandle;
}

inline GLSLReflection const& GLSLVisualProgram::GetReflector() const
{
    return mReflector;
}


}
