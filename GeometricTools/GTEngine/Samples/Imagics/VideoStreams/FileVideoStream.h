// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include "VideoStream.h"
#include <fstream>

class FileVideoStream : public VideoStream
{
public:
    // Construction and destruction.  The input file is binary with the
    // following structure:
    //   unsigned int numImages;
    //   DFType type;
    //   unsigned int width;
    //   unsigned int height;
    //   struct { unsigned int frameNumber; char data[N]; } image[numImages];
    // where N = width*height*TextureFormat::GetNumBytesPerTexel(type).  The
    // engine that stores the file images in GPU memory must be provided to the
    // constructor.  NOTE: No error checking is performed in the constructor.
    // The 'engine' must be nonnull and the file must exist and be of the
    // correct format.
    virtual ~FileVideoStream();
    FileVideoStream(std::string const& filename, gte::DX11Engine* engine);

    // Access to input information.
    std::string const& GetFilename() const;
    unsigned int GetNumImages() const;

private:
    // The override that is called by VideoStream::CaptureFrame().
    virtual char* GetImage();

    // The file and information corresponding to the video stream.  The
    // current image is tracked so that when it reaches the number of images,
    // it is wrapped around to zero.
    std::string mFilename;
    std::ifstream mInput;
    unsigned int mNumImages, mCurrentImage;

    // A temporary buffer for reading images from disk.
    std::vector<char> mBuffer;
};
