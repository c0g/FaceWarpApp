// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <LowLevel/GteLogger.h>
#include <Graphics/GL4/GteGLSLComputeProgram.h>
#include <Graphics/GL4/GteGLSLProgramFactory.h>
#include <Graphics/GL4/GteGLSLVisualProgram.h>
using namespace gte;

std::string GLSLProgramFactory::defaultVersion = "#version 430";
std::string GLSLProgramFactory::defaultVSEntry = "main";
std::string GLSLProgramFactory::defaultPSEntry = "main";
std::string GLSLProgramFactory::defaultGSEntry = "main";
std::string GLSLProgramFactory::defaultCSEntry = "main";
unsigned int GLSLProgramFactory::defaultFlags = 0;  // unused in GLSL for now


GLSLProgramFactory::~GLSLProgramFactory()
{
}

GLSLProgramFactory::GLSLProgramFactory()
{
    version = defaultVersion;
    vsEntry = defaultVSEntry;
    psEntry = defaultPSEntry;
    gsEntry = defaultGSEntry;
    csEntry = defaultCSEntry;
    flags = defaultFlags;
}

int GLSLProgramFactory::GetAPI() const
{
    return PF_GLSL;
}

std::shared_ptr<VisualProgram> GLSLProgramFactory::CreateFromNamedSources(
    std::string const&, std::string const& vsSource,
    std::string const&, std::string const& psSource,
    std::string const&, std::string const& gsSource)
{
    if (vsSource == "" || psSource == "")
    {
        LogError("A program must have a vertex shader and a pixel shader.");
        return nullptr;
    }

    GLuint vsHandle = Compile(GL_VERTEX_SHADER, vsSource);
    if (vsHandle == 0)
    {
        return nullptr;
    }

    GLuint psHandle = Compile(GL_FRAGMENT_SHADER, psSource);
    if (psHandle == 0)
    {
        return nullptr;
    }

    GLuint gsHandle = 0;
    if (gsSource != "")
    {
        gsHandle = Compile(GL_GEOMETRY_SHADER, gsSource);
        if (gsHandle == 0)
        {
            return nullptr;
        }
    }

    GLuint programHandle = glCreateProgram();
    if (programHandle == 0)
    {
        LogError("Program creation failed.");
        return nullptr;
    }

    glAttachShader(programHandle, vsHandle);
    glAttachShader(programHandle, psHandle);
    if (gsHandle > 0)
    {
        glAttachShader(programHandle, gsHandle);
    }

    if (!Link(programHandle))
    {
        glDetachShader(programHandle, vsHandle);
        glDeleteShader(vsHandle);
        glDetachShader(programHandle, psHandle);
        glDeleteShader(psHandle);
        if (gsHandle)
        {
            glDetachShader(programHandle, gsHandle);
            glDeleteShader(gsHandle);
        }
        glDeleteProgram(programHandle);
        return nullptr;
    }

    std::shared_ptr<GLSLVisualProgram> program =
        std::make_shared<GLSLVisualProgram>(programHandle, vsHandle,
        psHandle, gsHandle);

    GLSLReflection const& reflector = program->GetReflector();
    program->SetVShader(std::make_shared<VertexShader>(reflector));
    program->SetPShader(std::make_shared<PixelShader>(reflector));
    if (gsHandle > 0)
    {
        program->SetGShader(std::make_shared<GeometryShader>(reflector));
    }
    return program;
}

std::shared_ptr<ComputeProgram> GLSLProgramFactory::CreateFromNamedSource(
    std::string const&, std::string const& csSource)
{
    if (csSource == "")
    {
        LogError("A program must have a compute shader.");
        return nullptr;
    }

    GLuint csHandle = Compile(GL_COMPUTE_SHADER, csSource);
    if (csHandle == 0)
    {
        return nullptr;
    }

    GLuint programHandle = glCreateProgram();
    if (programHandle == 0)
    {
        LogError("Program creation failed.");
        return nullptr;
    }

    glAttachShader(programHandle, csHandle);

    if (!Link(programHandle))
    {
        glDetachShader(programHandle, csHandle);
        glDeleteShader(csHandle);
        glDeleteProgram(programHandle);
        return nullptr;
    }

    std::shared_ptr<GLSLComputeProgram> program =
        std::make_shared<GLSLComputeProgram>(programHandle, csHandle);

    GLSLReflection const& reflector = program->GetReflector();
    program->SetCShader(std::make_shared<ComputeShader>(reflector));
    return program;
}

GLuint GLSLProgramFactory::Compile(GLenum shaderType,
    std::string const& source)
{
    GLuint handle = glCreateShader(shaderType);
    if (handle > 0)
    {
        // Prepend to the definitions
        // 1. The version of the GLSL program; for example, "#version 400".
        // 2. A define for the matrix-vector multiplication convention if
        //    it is selected as GTE_USE_MAT_VEC: "define GTE_USE_MAT_VEC".
        // Append to the definitions the source-code string.
        auto const& definitions = defines.Get();
        std::vector<std::string> glslDefines;
        glslDefines.reserve(definitions.size() + 3);
        glslDefines.push_back(version + "\n");
#if defined(GTE_USE_MAT_VEC)
        glslDefines.push_back("#define GTE_USE_MAT_VEC\n");
#endif
        for (auto d : definitions)
        {
            glslDefines.push_back(d.first + " " + d.second + "\n");
        }
        glslDefines.push_back(source);

        // Repackage the definitions for glShaderSource.
        std::vector<GLchar const*> code;
        code.reserve(glslDefines.size());
        for (auto const& d : glslDefines)
        {
            code.push_back(d.c_str());
        }

        glShaderSource(handle, static_cast<GLsizei>(code.size()), &code[0],
            nullptr);

        glCompileShader(handle);
        GLint status;
        glGetShaderiv(handle, GL_COMPILE_STATUS, &status);
        if (status == GL_FALSE)
        {
            GLint logLength;
            glGetShaderiv(handle, GL_INFO_LOG_LENGTH, &logLength);
            if (logLength > 0)
            {
                GLchar* log = new GLchar[logLength];
                GLsizei numWritten;
                glGetShaderInfoLog(handle, static_cast<GLsizei>(logLength),
                    &numWritten, log);
                LogError("Compile failed:\n" + std::string(log));
                delete[] log;
            }
            else
            {
                LogError("Invalid info log length.");
            }
            glDeleteShader(handle);
            handle = 0;
        }
    }
    else
    {
        LogError("Cannot create shader.");
    }
    return handle;
}

bool GLSLProgramFactory::Link(GLuint programHandle)
{
    glLinkProgram(programHandle);
    int status;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
    {
        int logLength;
        glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0)
        {
            char* log = new char[logLength];
            int numWritten;
            glGetProgramInfoLog(programHandle, logLength, &numWritten, log);
            LogError("Link failed:\n" + std::string(log));
            delete[] log;
        }
        else
        {
            LogError("Invalid info log length.");
        }
        return false;
    }
    else
    {
        return true;
    }
}

