// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <Graphics/DX11/GteDX11TextureRT.h>
using namespace gte;


DX11TextureRT::~DX11TextureRT()
{
    FinalRelease(mRTView);
}

DX11TextureRT::DX11TextureRT(ID3D11Device* device, TextureRT const* texture)
    :
    DX11Texture2(texture),
    mRTView(nullptr)
{
    // Specify the texture description.
    D3D11_TEXTURE2D_DESC desc;
    desc.Width = texture->GetWidth();
    desc.Height = texture->GetHeight();
    desc.MipLevels = texture->GetNumLevels();
    desc.ArraySize = 1;
    desc.Format = static_cast<DXGI_FORMAT>(texture->GetFormat());
    desc.SampleDesc.Count = 1;
    desc.SampleDesc.Quality = 0;
    desc.Usage = D3D11_USAGE_DEFAULT;
    desc.BindFlags = D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_RENDER_TARGET;
    desc.CPUAccessFlags = D3D11_CPU_ACCESS_NONE;
    desc.MiscFlags = (texture->IsShared() ?
        D3D11_RESOURCE_MISC_SHARED : D3D11_RESOURCE_MISC_NONE);

    if (texture->GetUsage() == Resource::SHADER_OUTPUT)
    {
        desc.BindFlags |= D3D11_BIND_UNORDERED_ACCESS;
    }

    if (texture->WantAutogenerateMipmaps() && !texture->IsShared())
    {
        desc.MiscFlags |= D3D11_RESOURCE_MISC_GENERATE_MIPS;
    }

    // Create the texture.
    ID3D11Texture2D* dxTexture = nullptr;
    HRESULT hr;
    if (texture->GetData())
    {
        unsigned int const numSubresources = texture->GetNumSubresources();
        std::vector<D3D11_SUBRESOURCE_DATA> data(numSubresources);
        for (unsigned int index = 0; index < numSubresources; ++index)
        {
            auto sr = texture->GetSubresource(index);
            data[index].pSysMem = sr.data;
            data[index].SysMemPitch = sr.rowPitch;
            data[index].SysMemSlicePitch = 0;
        }
        hr = device->CreateTexture2D(&desc, &data[0], &dxTexture);
    }
    else
    {
        hr = device->CreateTexture2D(&desc, nullptr, &dxTexture);
    }
    CHECK_HR_RETURN_VOID("Failed to map create texture");
    mDXObject = dxTexture;

    // Create views of the texture.
    CreateSRView(device, desc);
    CreateRTView(device, desc);
    if (texture->GetUsage() == Resource::SHADER_OUTPUT)
    {
        CreateUAView(device, desc);
    }

    // Create a staging texture if requested.
    if (texture->GetCopyType() != Resource::COPY_NONE)
    {
        CreateStaging(device, desc);
    }
}

DX11TextureRT::DX11TextureRT(ID3D11Device* device,
    DX11TextureRT const* dxSharedTexture)
    :
    DX11Texture2(dxSharedTexture->GetTexture()),
    mRTView(nullptr)
{
    ID3D11Texture2D* dxShared = dxSharedTexture->CreateSharedDXObject(device);
    mDXObject = dxShared;
    D3D11_TEXTURE2D_DESC desc;
    dxShared->GetDesc(&desc);
    CreateRTView(device, desc);
}

DX11GraphicsObject* DX11TextureRT::Create(ID3D11Device* device,
    GraphicsObject const* object)
{
    if (object->GetType() == GT_TEXTURE_RT)
    {
        return new DX11TextureRT(device,
            static_cast<TextureRT const*>(object));
    }

    LogError("Invalid object type.");
    return nullptr;
}

ID3D11RenderTargetView* DX11TextureRT::GetRTView() const
{
    return mRTView;
}

void DX11TextureRT::CreateRTView(ID3D11Device* device,
    D3D11_TEXTURE2D_DESC const& tx)
{
    D3D11_RENDER_TARGET_VIEW_DESC desc;
    desc.Format = tx.Format;
    desc.ViewDimension = D3D11_RTV_DIMENSION_TEXTURE2D;
    desc.Texture2D.MipSlice = 0;

    HRESULT hr = device->CreateRenderTargetView(GetDXTexture(), &desc,
        &mRTView);
    CHECK_HR_RETURN_NONE("Failed to create render-target view");
}

void DX11TextureRT::SetName(std::string const& name)
{
    DX11Texture2::SetName(name);
    HRESULT hr = SetPrivateName(mRTView, name);
    CHECK_HR_RETURN_NONE("Failed to set private name");
}

