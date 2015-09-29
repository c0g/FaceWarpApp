// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Graphics/GteResource.h>
#include <Graphics/DX11/GteDX11GraphicsObject.h>

namespace gte
{

class GTE_IMPEXP DX11Resource : public DX11GraphicsObject
{
public:
    // Abstract base class.
    virtual ~DX11Resource();
protected:
    DX11Resource(Resource const* gtResource);

public:
    // Member access.
    Resource* GetResource() const;
    ID3D11Resource* GetDXResource() const;
    ID3D11Resource* GetStagingResource() const;

    // Copy data from CPU to GPU via mapped memory for the specified
    // subresource.  The mapping is successful iff the returned struct's
    // pData member is not null.  The caller is responsible for using the
    // row pitch and slice pitch correctly when writing to the memory.
    D3D11_MAPPED_SUBRESOURCE MapForWrite(ID3D11DeviceContext* context,
        unsigned int sri);
    void Unmap(ID3D11DeviceContext* context, unsigned int sri);

    // Copy from CPU (mGTObject memory) to GPU (mDXObject memory).  The first
    // function copies the specified subresource.  The second function copies
    // all subresources.
    virtual bool Update(ID3D11DeviceContext* context, unsigned int sri) = 0;
    virtual bool Update(ID3D11DeviceContext* context) = 0;

    // Copy from CPU to GPU using staging buffers.  The first function copies
    // the specified subresource.  The second function copies all subresources.
    virtual bool CopyCpuToGpu(ID3D11DeviceContext* context,
        unsigned int sri) = 0;
    virtual bool CopyCpuToGpu(ID3D11DeviceContext* context) = 0;

    // Copy from GPU to CPU using staging buffers.  The first function copies
    // the specified subresource.  The second function copies all subresources.
    virtual bool CopyGpuToCpu(ID3D11DeviceContext* context,
        unsigned int sri) = 0;
    virtual bool CopyGpuToCpu(ID3D11DeviceContext* context) = 0;

protected:
    // Support for copying between CPU and GPU.
    bool PreparedForCopy(D3D11_CPU_ACCESS_FLAG access) const;

    // A staging buffer is used for copying between CPU and GPU memory.
    ID3D11Resource* mStaging;

    // Mapping from Resource::CopyType to D3D11_CPU_ACCESS_FLAG.
    static UINT const msStagingAccess[];

public:
    // Support for the DX11 debug layer; see comments in the file
    // GteDX11GraphicsObject.h about usage.
    virtual void SetName(std::string const& name);
};

}
