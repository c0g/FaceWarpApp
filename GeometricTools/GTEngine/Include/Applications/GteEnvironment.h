// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <GTEngineDEF.h>
#include <string>
#include <vector>

namespace gte
{

class GTE_IMPEXP Environment
{
public:
    // Construction and destruction.
    ~Environment();
    Environment();

    // Get the string corresponding to an environment variable.
    std::string GetVariable(std::string const& name);

    // Support for paths to locate files.  For platform independence, use
    // "/" for the path separator.  The input 'directory' will automatically
    // be appended with a trailing "/" if it does not end in '/' or '\\'. 
    // The Insert*/Remove* functions return 'true' iff the operation was
    // successful.
    int GetNumDirectories() const;
    std::string Get(int i) const;
    bool Insert(std::string const& directory);
    bool Remove(std::string const& directory);
    void RemoveAll();

    // Support for path components.
    static bool SplitPath(std::string const& path, std::string& drive,
        std::string& directory, std::string& name, std::string& extension);

    static bool FullPath(std::string const& relativePath,
        std::string& fullPath);

    // The GetPath function searches the list of directories and returns the
    // fully decorated file name, assuming it has the required modes, or
    // returns the empty string if conditions are not met.
    enum FileMode
    {
        FM_EXISTS,
        FM_READABLE,
        FM_WRITABLE
    };
    std::string GetPath(std::string const& name, FileMode mode = FM_READABLE)
        const;

    // String formatting operations.
    static std::string CreateString(char const* format, ...);
    static std::string CreateStringFromArgs(char const* format,
        va_list arguments);
    static std::wstring CreateString(wchar_t const* format, ...);
    static std::wstring CreateStringFromArgs(wchar_t const* format,
        va_list arguments);

    // Conversions between single-character and wide-character strings.
    static std::wstring Convert(std::string const& input);
    static std::string Convert(std::wstring const& input);

private:
    // The list of directories for GetPath to search.
    std::vector<std::string> mDirectories;
};

}
