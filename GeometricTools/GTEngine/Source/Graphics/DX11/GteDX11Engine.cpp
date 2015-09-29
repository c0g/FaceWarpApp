// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <Mathematics/GteBitHacks.h>
#include <Graphics/GteComputeShader.h>
#include <Graphics/GteFontArialW400H18.h>
#include <Graphics/GteOverlayEffect.h>
#include <Graphics/GteVisual.h>
#include <Graphics/GteVisualEffect.h>
#include <Graphics/DX11/GteDX11Engine.h>
#include <Graphics/DX11/GteDX11BlendState.h>
#include <Graphics/DX11/GteDX11ComputeShader.h>
#include <Graphics/DX11/GteDX11ConstantBuffer.h>
#include <Graphics/DX11/GteDX11DepthStencilState.h>
#include <Graphics/DX11/GteDX11DrawTarget.h>
#include <Graphics/DX11/GteDX11GeometryShader.h>
#include <Graphics/DX11/GteDX11IndexBuffer.h>
#include <Graphics/DX11/GteDX11IndirectArgumentsBuffer.h>
#include <Graphics/DX11/GteDX11InputLayoutManager.h>
#include <Graphics/DX11/GteDX11PixelShader.h>
#include <Graphics/DX11/GteDX11RasterizerState.h>
#include <Graphics/DX11/GteDX11RawBuffer.h>
#include <Graphics/DX11/GteDX11SamplerState.h>
#include <Graphics/DX11/GteDX11StructuredBuffer.h>
#include <Graphics/DX11/GteDX11Texture1.h>
#include <Graphics/DX11/GteDX11Texture2.h>
#include <Graphics/DX11/GteDX11Texture3.h>
#include <Graphics/DX11/GteDX11TextureCube.h>
#include <Graphics/DX11/GteDX11Texture1Array.h>
#include <Graphics/DX11/GteDX11Texture2Array.h>
#include <Graphics/DX11/GteDX11TextureCubeArray.h>
#include <Graphics/DX11/GteDX11TextureBuffer.h>
#include <Graphics/DX11/GteDX11VertexBuffer.h>
#include <Graphics/DX11/GteDX11VertexShader.h>
#include <Graphics/DX11/GteHLSLProgramFactory.h>
using namespace gte;


DX11Engine::~DX11Engine()
{
    // The render state objects (and fonts) are destroyed first so that the
    // render state objects are removed from the bridges before they are
    // cleared later in the destructor.
    DestroyDefaultObjects();

    GraphicsObject::UnsubscribeForDestruction(mGOListener);
    delete mGOListener;

    DrawTarget::UnsubscribeForDestruction(mDTListener);
    delete mDTListener;

    if (mGOMap.HasElements())
    {
        if (mWarnOnNonemptyBridges)
        {
            LogWarning("Bridge map is nonempty on destruction.");
        }

        std::vector<DX11GraphicsObject*> objects;
        mGOMap.GatherAll(objects);
        for (auto object : objects)
        {
            delete object;
        }
        mGOMap.RemoveAll();
    }

    if (mDTMap.HasElements())
    {
        if (mWarnOnNonemptyBridges)
        {
            LogWarning("Draw target map nonempty on destruction.");
        }

        std::vector<DX11DrawTarget*> targets;
        mDTMap.GatherAll(targets);
        for (auto target : targets)
        {
            delete target;
        }
        mDTMap.RemoveAll();
    }

    if (mILMap.HasElements())
    {
        if (mWarnOnNonemptyBridges)
        {
            LogWarning("Input layout map nonempty on destruction.");
        }

        mILMap.UnbindAll();
    }

    DestroyBackBuffer();
    DestroySwapChain();
    DestroyDevice();
}

DX11Engine::DX11Engine(D3D_FEATURE_LEVEL minFeatureLevel)
{
    Initialize(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, 0,
        minFeatureLevel);
    CreateDevice();
}

DX11Engine::DX11Engine(IDXGIAdapter* adapter, D3D_DRIVER_TYPE driverType,
    HMODULE softwareModule, UINT flags, D3D_FEATURE_LEVEL minFeatureLevel)
{
    Initialize(adapter, driverType, softwareModule, flags, minFeatureLevel);
    CreateDevice();
}

DX11Engine::DX11Engine(HWND handle, UINT xSize, UINT ySize,
    D3D_FEATURE_LEVEL minFeatureLevel)
{
    Initialize(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, 0,
        minFeatureLevel);

    if (CreateDevice()
    &&  CreateSwapChain(handle, xSize, ySize)
    &&  CreateBackBuffer(xSize, ySize))
    {
        CreateDefaultObjects();
        return;
    }

    DestroyDefaultObjects();
    DestroyBackBuffer();
    DestroySwapChain();
    DestroyDevice();
}

DX11Engine::DX11Engine(IDXGIAdapter* adapter, HWND handle, UINT xSize,
    UINT ySize, D3D_DRIVER_TYPE driverType, HMODULE softwareModule,
    UINT flags, D3D_FEATURE_LEVEL minFeatureLevel)
{
    Initialize(adapter, driverType, softwareModule, flags, minFeatureLevel);

    if (CreateDevice()
    &&  CreateSwapChain(handle, xSize, ySize)
    &&  CreateBackBuffer(xSize, ySize))
    {
        CreateDefaultObjects();
        return;
    }

    DestroyDefaultObjects();
    DestroyBackBuffer();
    DestroySwapChain();
    DestroyDevice();
}

void DX11Engine::Initialize(IDXGIAdapter* adapter, D3D_DRIVER_TYPE driverType,
    HMODULE softwareModule, UINT flags, D3D_FEATURE_LEVEL minFeatureLevel)
{
    mThreadID = GetCurrentThreadId();

    mAdapter = adapter;
    mDriverType = driverType;
    mSoftwareModule = softwareModule;
    mFlags = flags;
    mMinFeatureLevel = minFeatureLevel;
    mDevice = nullptr;
    mImmediate = nullptr;
    mFeatureLevel = D3D_FEATURE_LEVEL_9_1;

    mXSize = 0;
    mYSize = 0;
    mSwapChain = nullptr;
    mColorBuffer = nullptr;
    mColorView = nullptr;
    mDepthStencilBuffer = nullptr;
    mDepthStencilView = nullptr;
    mViewport.TopLeftX = 0.0f;
    mViewport.TopLeftY = 0.0f;
    mViewport.Width = 0.0f;
    mViewport.Height = 0.0f;
    mViewport.MinDepth = 0.0f;
    mViewport.MaxDepth = 0.0f;

    mNumActiveRTs = 0;
    for (int i = 0; i < D3D11_SIMULTANEOUS_RENDER_TARGET_COUNT; ++i)
    {
        mActiveRT[i] = nullptr;
    }
    mActiveDS = nullptr;
    mSaveViewport = mViewport;
    for (int i = 0; i < D3D11_SIMULTANEOUS_RENDER_TARGET_COUNT; ++i)
    {
        mSaveRT[i] = nullptr;
    }
    mSaveDS = nullptr;

    mClearColor[0] = 1.0f;
    mClearColor[1] = 1.0f;
    mClearColor[2] = 1.0f;
    mClearColor[3] = 1.0f;
    mClearDepth = 1.0f;
    mClearStencil = 0;

    mDefaultBlendState = nullptr;
    mActiveBlendState = nullptr;
    mDefaultDepthStencilState = nullptr;
    mActiveDepthStencilState = nullptr;
    mDefaultRasterizerState = nullptr;
    mActiveRasterizerState = nullptr;

    mDefaultFont = nullptr;
    mActiveFont = nullptr;

    mGOListener = new GOListener(this);
    GraphicsObject::SubscribeForDestruction(mGOListener);

    mDTListener = new DTListener(this);
    DrawTarget::SubscribeForDestruction(mDTListener);

    mAllowOcclusionQuery = false;
    mWarnOnNonemptyBridges = true;
}

bool DX11Engine::CreateDevice()
{
    // Determine the subarray for creating the device.
    UINT const maxFeatureLevels = 7;
    D3D_FEATURE_LEVEL const featureLevels[maxFeatureLevels] =
    {
        D3D_FEATURE_LEVEL_11_1,
        D3D_FEATURE_LEVEL_11_0,
        D3D_FEATURE_LEVEL_10_1,
        D3D_FEATURE_LEVEL_10_0,
        D3D_FEATURE_LEVEL_9_3,
        D3D_FEATURE_LEVEL_9_2,
        D3D_FEATURE_LEVEL_9_1
    };

    UINT numFeatureLevels = 1;
    for (UINT i = 0; i < maxFeatureLevels; ++i, ++numFeatureLevels)
    {
        if (mMinFeatureLevel == featureLevels[i])
        {
            break;
        }
    }

    // Create the device and device context.
    if (mAdapter && mDriverType != D3D_DRIVER_TYPE_UNKNOWN)
    {
        mDriverType = D3D_DRIVER_TYPE_UNKNOWN;
        LogWarning("Nonnull adapter requires D3D_DRIVER_TYPE_UNKNOWN.");
    }

    HRESULT hr = D3D11CreateDevice(mAdapter, mDriverType, mSoftwareModule,
        mFlags, featureLevels, numFeatureLevels, D3D11_SDK_VERSION, &mDevice,
        &mFeatureLevel, &mImmediate);
    CHECK_HR_RETURN("Failed to create device", false);
    return true;
}

bool DX11Engine::CreateSwapChain(HWND handle, UINT xSize, UINT ySize)
{
    mXSize = xSize;
    mYSize = ySize;

    struct DXGIInterfaces
    {
        DXGIInterfaces()
            :
            device(nullptr),
            adapter(nullptr),
            factory(nullptr)
        {
        }

        ~DXGIInterfaces()
        {
            SafeRelease(factory);
            SafeRelease(adapter);
            SafeRelease(device);
        }

        IDXGIDevice* device;
        IDXGIAdapter* adapter;
        IDXGIFactory1* factory;
    };

    DXGIInterfaces dxgi;
    HRESULT hr = mDevice->QueryInterface(__uuidof(IDXGIDevice),
        (void**)&dxgi.device);
    CHECK_HR_RETURN("Failed to get DXGI device interface", false);

    hr = dxgi.device->GetAdapter(&dxgi.adapter);
    CHECK_HR_RETURN("Failed to get DXGI adapter", false);

    hr = dxgi.adapter->GetParent(__uuidof(IDXGIFactory1),
        (void**)&dxgi.factory);
    CHECK_HR_RETURN("Failed to get DXGI factory", false);

    DXGI_SWAP_CHAIN_DESC desc;
    desc.BufferDesc.Width = xSize;
    desc.BufferDesc.Height = ySize;
    desc.BufferDesc.RefreshRate.Numerator = 0;
    desc.BufferDesc.RefreshRate.Denominator = 1;
    desc.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    desc.BufferDesc.ScanlineOrdering = DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED;
    desc.BufferDesc.Scaling = DXGI_MODE_SCALING_UNSPECIFIED;
    desc.SampleDesc.Count = 1;
    desc.SampleDesc.Quality = 0;
    desc.BufferUsage =
        DXGI_USAGE_BACK_BUFFER | DXGI_USAGE_RENDER_TARGET_OUTPUT;
    desc.BufferCount = 2;
    desc.OutputWindow = handle;
    desc.Windowed = TRUE;
    desc.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;
    desc.Flags = 0;

    hr = dxgi.factory->CreateSwapChain(dxgi.device, &desc, &mSwapChain);
    CHECK_HR_RETURN("Failed to create swap chain", false);

#if defined(GTE_USE_NAMED_DX11_OBJECTS)
    hr = SetPrivateName(mSwapChain, "DX11Engine::mSwapChain");
    LogAssert(SUCCEEDED(hr), "Failed to set private name, hr = " +
        std::to_string(hr));
#endif

    return true;
}

bool DX11Engine::CreateBackBuffer(UINT xSize, UINT ySize)
{
    struct BackBuffer
    {
        BackBuffer()
        {
            SetToNull();
        }

        ~BackBuffer()
        {
            SafeRelease(depthStencilView);
            SafeRelease(depthStencilBuffer);
            SafeRelease(colorView);
            SafeRelease(colorBuffer);
        }

        void SetToNull()
        {
            colorBuffer = nullptr;
            colorView = nullptr;
            depthStencilBuffer = nullptr;
            depthStencilView = nullptr;
        }

        ID3D11Texture2D* colorBuffer;
        ID3D11RenderTargetView* colorView;
        ID3D11Texture2D* depthStencilBuffer;
        ID3D11DepthStencilView* depthStencilView;
    };

    BackBuffer bb;

    // Create the color buffer and its view.
    HRESULT hr = mSwapChain->GetBuffer(0, __uuidof(ID3D11Texture2D),
        reinterpret_cast<void**>(&bb.colorBuffer));
    CHECK_HR_RETURN("Failed to get color buffer", false);

#if defined(GTE_USE_NAMED_DX11_OBJECTS)
    hr = SetPrivateName(bb.colorBuffer, "DX11Engine::mColorBuffer");
    LogAssert(SUCCEEDED(hr), "Failed to set private name, hr = " +
        std::to_string(hr));
#endif

    hr = mDevice->CreateRenderTargetView(bb.colorBuffer, nullptr,
        &bb.colorView);
    CHECK_HR_RETURN("Failed to create color view", false);

#if defined(GTE_USE_NAMED_DX11_OBJECTS)
    hr = SetPrivateName(bb.colorView, "DX11Engine::mColorView");
    LogAssert(SUCCEEDED(hr), "Failed to set private name, hr = " +
        std::to_string(hr));
#endif

    // Create the depth-stencil buffer and its view.
    D3D11_TEXTURE2D_DESC desc;
    desc.Width = xSize;
    desc.Height = ySize;
    desc.MipLevels = 1;
    desc.ArraySize = 1;
    desc.Format = DXGI_FORMAT_D24_UNORM_S8_UINT;
    desc.SampleDesc.Count = 1;
    desc.SampleDesc.Quality = 0;
    desc.Usage = D3D11_USAGE_DEFAULT;
    desc.BindFlags = D3D11_BIND_DEPTH_STENCIL;
    desc.CPUAccessFlags = D3D11_CPU_ACCESS_NONE;
    desc.MiscFlags = D3D11_RESOURCE_MISC_NONE;

    hr = mDevice->CreateTexture2D(&desc, nullptr, &bb.depthStencilBuffer);
    CHECK_HR_RETURN("Failed to create depth-stencil buffer", false);

#if defined(GTE_USE_NAMED_DX11_OBJECTS)
    hr = SetPrivateName(bb.depthStencilBuffer,
        "DX11Engine::mDepthStencilBuffer");
    LogAssert(SUCCEEDED(hr), "Failed to set private name, hr = " +
        std::to_string(hr));
#endif

    hr = mDevice->CreateDepthStencilView(bb.depthStencilBuffer, nullptr,
        &bb.depthStencilView);
    CHECK_HR_RETURN("Failed to create depth-stencil view", false);

#if defined(GTE_USE_NAMED_DX11_OBJECTS)
    hr = SetPrivateName(bb.depthStencilView, "DX11Engine::mDepthStencilView");
    LogAssert(SUCCEEDED(hr), "Failed to set private name, hr = " +
        std::to_string(hr));
#endif

    // The back buffer has been created successfully.  Transfer the
    // resources to 'this' members.
    mColorBuffer = bb.colorBuffer;
    mColorView = bb.colorView;
    mDepthStencilBuffer = bb.depthStencilBuffer;
    mDepthStencilView = bb.depthStencilView;
    bb.SetToNull();

    mViewport.Width = static_cast<float>(xSize);
    mViewport.Height = static_cast<float>(ySize);
    mViewport.TopLeftX = 0.0f;
    mViewport.TopLeftY = 0.0f;
    mViewport.MinDepth = 0.0f;
    mViewport.MaxDepth = 1.0f;
    mImmediate->RSSetViewports(1, &mViewport);

    mNumActiveRTs = 1;
    mActiveRT[0] = mColorView;
    mActiveDS = mDepthStencilView;
    mImmediate->OMSetRenderTargets(1, mActiveRT, mActiveDS);
    return true;
}

void DX11Engine::CreateDefaultObjects()
{
    HLSLProgramFactory factory;
    mDefaultFont = std::make_shared<FontArialW400H18>(factory, 256);
    mDefaultBlendState = std::make_shared<BlendState>();
    mDefaultDepthStencilState = std::make_shared<DepthStencilState>();
    mDefaultRasterizerState = std::make_shared<RasterizerState>();

#if defined(GTE_USE_NAMED_DX11_OBJECTS)
    mDefaultBlendState->SetName(
        "DX11Engine::mDefaultBlendState");
    mDefaultDepthStencilState->SetName(
        "DX11Engine::mDefaultDepthStencilState");
    mDefaultRasterizerState->SetName(
        "DX11Engine::mDefaultRasterizerState");
#endif

    SetDefaultFont();
    SetDefaultBlendState();
    SetDefaultDepthStencilState();
    SetDefaultRasterizerState();
}

void DX11Engine::DestroyDefaultObjects()
{
    if (mDefaultFont)
    {
        mDefaultFont = nullptr;
        mActiveFont = nullptr;
    }

    if (mDefaultBlendState)
    {
        Unbind(mDefaultBlendState);
        mDefaultBlendState = nullptr;
        mActiveBlendState = nullptr;
    }

    if (mDefaultDepthStencilState)
    {
        Unbind(mDefaultDepthStencilState);
        mDefaultDepthStencilState = nullptr;
        mActiveDepthStencilState = nullptr;
    }

    if (mDefaultRasterizerState)
    {
        Unbind(mDefaultRasterizerState);
        mDefaultRasterizerState = nullptr;
        mActiveRasterizerState = nullptr;
    }
}

bool DX11Engine::DestroyDevice()
{
    return FinalRelease(mImmediate) == 0 && FinalRelease(mDevice) == 0;
}

bool DX11Engine::DestroySwapChain()
{
    bool successful = true;
    ULONG refs;

    if (mSwapChain)
    {
        refs = mSwapChain->Release();
        if (refs > 0)
        {
            LogError("Swap chain not released.");
            successful = false;
        }
        mSwapChain = nullptr;
    }

    return successful;
}

bool DX11Engine::DestroyBackBuffer()
{
    if (mImmediate)
    {
        ID3D11RenderTargetView* rtView = nullptr;
        ID3D11DepthStencilView* dsView = nullptr;
        mImmediate->OMSetRenderTargets(1, &rtView, dsView);
    }

    mActiveRT[0] = nullptr;
    mActiveDS = nullptr;

    return FinalRelease(mColorView) == 0
        && FinalRelease(mColorBuffer) == 0
        && FinalRelease(mDepthStencilView) == 0
        && FinalRelease(mDepthStencilBuffer) == 0;
}

DX11GraphicsObject* DX11Engine::Bind(
    std::shared_ptr<GraphicsObject> const& object)
{
    if (!object)
    {
        LogError("Attempt to bind a null object.");
        return nullptr;
    }

    GraphicsObject const* gtObject = object.get();
    DX11GraphicsObject* dxObject = nullptr;
    if (!mGOMap.Get(gtObject, dxObject))
    {
        // The 'create' function is not null with the current engine design.
        // If the assertion is triggered, someone changed the hierarchy of
        // GraphicsObjectType but did not change msCreateFunctions[] to match.
        CreateFunction create = msCreateFunctions[object->GetType()];
        LogAssert(create, "Null creation function.");

        dxObject = create(mDevice, gtObject);
        LogAssert(dxObject, "Null dxObject.  Out of memory?");

        mGOMap.Insert(gtObject, dxObject);
#if defined(GTE_USE_NAMED_DX11_OBJECTS)
        dxObject->SetName(object->GetName());
#endif

        // Autogenerate the miplevels on creation in case the application
        // did not manually generate them before the Bind() call.  The
        // creation gets only mDevice but the autogeneration requires a
        // context, which is why the code is here.  TODO: Can this be
        // factored out of here and made automatic somwhere else?
        if (object->IsTexture())
        {
            Texture const* texture = static_cast<Texture const*>(gtObject);
            if (texture->WantAutogenerateMipmaps())
            {
                DX11Texture* dxTexture = static_cast<DX11Texture*>(dxObject);
                ID3D11ShaderResourceView* srView = dxTexture->GetSRView();
                if (srView)
                {
                    mImmediate->GenerateMips(dxTexture->GetSRView());
                }
            }
        }
        else if (object->IsTextureArray())
        {
            TextureArray const* textureArray =
                static_cast<TextureArray const*>(gtObject);
            if (textureArray->WantAutogenerateMipmaps())
            {
                DX11TextureArray* dxTextureArray =
                    static_cast<DX11TextureArray*>(dxObject);
                ID3D11ShaderResourceView* srView = dxTextureArray->GetSRView();
                if (srView)
                {
                    mImmediate->GenerateMips(dxTextureArray->GetSRView());
                }
            }
        }
    }
    return dxObject;
}

DX11GraphicsObject* DX11Engine::Get(
    std::shared_ptr<GraphicsObject> const& object) const
{
    GraphicsObject const* gtObject = object.get();
    DX11GraphicsObject* dxObject = nullptr;
    if (mGOMap.Get(gtObject, dxObject))
    {
        return dxObject;
    }
    return nullptr;
}

DX11DrawTarget* DX11Engine::Bind(std::shared_ptr<DrawTarget> const& target)
{
    DrawTarget const* gtTarget = target.get();
    DX11DrawTarget* dxTarget = nullptr;
    if (!mDTMap.Get(gtTarget, dxTarget))
    {
        unsigned int const numTargets = target->GetNumTargets();
        std::vector<DX11TextureRT*> rtTextures(numTargets);
        for (unsigned int i = 0; i < numTargets; ++i)
        {
            rtTextures[i] = static_cast<DX11TextureRT*>(
                Bind(target->GetRTTexture(i)));
        }

        std::shared_ptr<TextureDS> object = target->GetDSTexture();
        DX11TextureDS* dsTexture;
        if (object)
        {
            dsTexture = static_cast<DX11TextureDS*>(Bind(object));
        }
        else
        {
            dsTexture = nullptr;
        }

        dxTarget = new DX11DrawTarget(gtTarget, rtTextures, dsTexture);
        mDTMap.Insert(gtTarget, dxTarget);
    }
    return dxTarget;
}

DX11DrawTarget* DX11Engine::Get(
    std::shared_ptr<DrawTarget> const& target) const
{
    DrawTarget const* gtTarget = target.get();
    DX11DrawTarget* dxTarget = nullptr;
    if (!mDTMap.Get(gtTarget, dxTarget))
    {
        LogWarning("Cannot find draw target.");
    }
    return dxTarget;
}

size_t DX11Engine::GetTotalAllocation(size_t& numObjects) const
{
    size_t totalMem = 0;
    numObjects = 0;
    std::vector<DX11GraphicsObject*> values;
    mGOMap.GatherAll(values);
    for (auto v : values)
    {
        if (v)
        {
            auto obj = dynamic_cast<Resource*>(v->GetGraphicsObject());
            if (obj)
            {
                numObjects++;
                totalMem += obj->GetNumBytes();
            }
        }
    }

    return totalMem;
}

bool DX11Engine::Unbind(GraphicsObject const* object)
{
    DX11GraphicsObject* dxObject = nullptr;
    if (mGOMap.Get(object, dxObject))
    {
        GraphicsObjectType type = object->GetType();
        if (type == GT_VERTEX_BUFFER)
        {
            mILMap.Unbind(static_cast<VertexBuffer const*>(object));
        }
        else if (type == GT_VERTEX_SHADER)
        {
            mILMap.Unbind(static_cast<Shader const*>(object));
        }

        if (mGOMap.Remove(object, dxObject))
        {
            delete dxObject;
        }

        return true;
    }
    return false;
}

bool DX11Engine::Unbind(DrawTarget const* target)
{
    DX11DrawTarget* dxTarget = nullptr;
    if (mDTMap.Remove(target, dxTarget))
    {
        delete dxTarget;
        return true;
    }

    return false;
}

DX11GraphicsObject* DX11Engine::Share(
    std::shared_ptr<Texture2> const& texture, DX11Engine* engine)
{
    if (!texture || !engine)
    {
        LogError("The inputs must be nonnull.");
        return nullptr;
    }

    if (!texture->IsShared())
    {
        LogError("The texture must allow sharing.");
        return nullptr;
    }

    DX11GraphicsObject* dxTexture = Get(texture);
    if (dxTexture)
    {
        // The texture is already shared by 'this', so nothing to do.
        return dxTexture;
    }

    dxTexture = engine->Get(texture);
    if (dxTexture)
    {
        DX11GraphicsObject* dxShared;
        if (texture->GetType() == GT_TEXTURE2)
        {
            dxShared = new DX11Texture2(mDevice,
                static_cast<DX11Texture2 const*>(dxTexture));
        }
        else if (texture->GetType() == GT_TEXTURE_RT)
        {
            dxShared = new DX11TextureRT(mDevice,
                static_cast<DX11TextureRT const*>(dxTexture));
        }
        else // texture->GetType() == GT_TEXTURE_DS
        {
            dxShared = new DX11TextureDS(mDevice,
                static_cast<DX11TextureDS const*>(dxTexture));
        }
        mGOMap.Insert(texture.get(), dxShared);
        return dxTexture;
    }

    // The texture is not bound to 'engine'; create a new binding for 'this'.
    return Bind(texture);
}

D3D11_MAPPED_SUBRESOURCE DX11Engine::MapForWrite(
    std::shared_ptr<Resource> const& resource, unsigned int sri)
{
    if (!resource->GetData())
    {
        LogWarning("Resource does not have system memory, creating it.");
        resource->CreateStorage();
    }

    DX11Resource* dxResource = static_cast<DX11Resource*>(Bind(resource));
    return dxResource->MapForWrite(mImmediate, sri);
}

void DX11Engine::Unmap(std::shared_ptr<Resource> const& resource,
    unsigned int sri)
{
    DX11Resource* dxResource = static_cast<DX11Resource*>(Bind(resource));
    dxResource->Unmap(mImmediate, sri);
}

bool DX11Engine::Update(std::shared_ptr<Buffer> const& buffer)
{
    if (!buffer->GetData())
    {
        LogWarning("Buffer does not have system memory, creating it.");
        buffer->CreateStorage();
    }

    DX11Buffer* dxBuffer = static_cast<DX11Buffer*>(Bind(buffer));
    return dxBuffer->Update(mImmediate);
}

bool DX11Engine::Update(std::shared_ptr<Texture> const& texture)
{
    if (!texture->GetData())
    {
        LogWarning("Texture does not have system memory, creating it.");
        texture->CreateStorage();
    }

    DX11Texture* dxTexture = static_cast<DX11Texture*>(Bind(texture));
    return dxTexture->Update(mImmediate);
}

bool DX11Engine::Update(std::shared_ptr<Texture> const& texture,
    unsigned int level)
{
    if (!texture->GetData())
    {
        LogWarning("Texture does not have system memory, creating it.");
        texture->CreateStorage();
    }

    DX11Texture* dxTexture = static_cast<DX11Texture*>(Bind(texture));
    unsigned int sri = texture->GetIndex(0, level);
    return dxTexture->Update(mImmediate, sri);
}

bool DX11Engine::Update(std::shared_ptr<TextureArray> const& textureArray)
{
    if (!textureArray->GetData())
    {
        LogWarning("Texture array does not have system memory, creating it.");
        textureArray->CreateStorage();
    }

    DX11TextureArray* dxTextureArray = static_cast<DX11TextureArray*>(
        Bind(textureArray));
    return dxTextureArray->Update(mImmediate);
}

bool DX11Engine::Update(std::shared_ptr<TextureArray> const& textureArray,
    unsigned int item, unsigned int level)
{
    if (!textureArray->GetData())
    {
        LogWarning("Texture array does not have system memory, creating it.");
        textureArray->CreateStorage();
    }

    DX11TextureArray* dxTextureArray = static_cast<DX11TextureArray*>(
        Bind(textureArray));
    unsigned int sri = textureArray->GetIndex(item, level);
    return dxTextureArray->Update(mImmediate, sri);
}

bool DX11Engine::CopyCpuToGpu(std::shared_ptr<Buffer> const& buffer)
{
    if (!buffer->GetData())
    {
        LogWarning("Buffer does not have system memory, creating it.");
        buffer->CreateStorage();
    }

    DX11Buffer* dxBuffer = static_cast<DX11Buffer*>(Bind(buffer));
    return dxBuffer->CopyCpuToGpu(mImmediate);
}

bool DX11Engine::CopyCpuToGpu(std::shared_ptr<Texture> const& texture)
{
    if (!texture->GetData())
    {
        LogWarning("Texture does not have system memory, creating it.");
        texture->CreateStorage();
    }

    DX11Texture* dxTexture = static_cast<DX11Texture*>(Bind(texture));
    return dxTexture->CopyCpuToGpu(mImmediate);
}

bool DX11Engine::CopyCpuToGpu(std::shared_ptr<Texture> const& texture,
    unsigned int level)
{
    if (!texture->GetData())
    {
        LogWarning("Texture does not have system memory, creating it.");
        texture->CreateStorage();
    }

    DX11Texture* dxTexture = static_cast<DX11Texture*>(Bind(texture));
    unsigned int sri = texture->GetIndex(0, level);
    return dxTexture->CopyCpuToGpu(mImmediate, sri);
}

bool DX11Engine::CopyCpuToGpu(
    std::shared_ptr<TextureArray> const& textureArray)
{
    if (!textureArray->GetData())
    {
        LogWarning("Texture array does not have system memory, creating it.");
        textureArray->CreateStorage();
    }

    DX11TextureArray* dxTextureArray = static_cast<DX11TextureArray*>(
        Bind(textureArray));
    return dxTextureArray->CopyCpuToGpu(mImmediate);
}

bool DX11Engine::CopyCpuToGpu(
    std::shared_ptr<TextureArray> const& textureArray, unsigned int item,
    unsigned int level)
{
    if (!textureArray->GetData())
    {
        LogWarning("Texture array does not have system memory, creating it.");
        textureArray->CreateStorage();
    }

    DX11TextureArray* dxTextureArray = static_cast<DX11TextureArray*>(
        Bind(textureArray));
    unsigned int sri = textureArray->GetIndex(item, level);
    return dxTextureArray->CopyCpuToGpu(mImmediate, sri);
}

bool DX11Engine::CopyGpuToCpu(std::shared_ptr<Buffer> const& buffer)
{
    if (!buffer->GetData())
    {
        LogWarning("Buffer does not have system memory, creating it.");
        buffer->CreateStorage();
    }

    DX11Buffer* dxBuffer = static_cast<DX11Buffer*>(Bind(buffer));
    return dxBuffer->CopyGpuToCpu(mImmediate);
}

bool DX11Engine::CopyGpuToCpu(std::shared_ptr<Texture> const& texture)
{
    if (!texture->GetData())
    {
        LogWarning("Texture does not have system memory, creating it.");
        texture->CreateStorage();
    }

    DX11Texture* dxTexture = static_cast<DX11Texture*>(Bind(texture));
    return dxTexture->CopyGpuToCpu(mImmediate);
}

bool DX11Engine::CopyGpuToCpu(std::shared_ptr<Texture> const& texture,
    unsigned int level)
{
    if (!texture->GetData())
    {
        LogWarning("Texture does not have system memory, creating it.");
        texture->CreateStorage();
    }

    DX11Texture* dxTexture = static_cast<DX11Texture*>(Bind(texture));
    unsigned int sri = texture->GetIndex(0, level);
    return dxTexture->CopyGpuToCpu(mImmediate, sri);
}

bool DX11Engine::CopyGpuToCpu(
    std::shared_ptr<TextureArray> const& textureArray)
{
    if (!textureArray->GetData())
    {
        LogWarning("Texture array does not have system memory, creating it.");
        textureArray->CreateStorage();
    }

    DX11TextureArray* dxTextureArray = static_cast<DX11TextureArray*>(
        Bind(textureArray));
    return dxTextureArray->CopyGpuToCpu(mImmediate);
}

bool DX11Engine::CopyGpuToCpu(
    std::shared_ptr<TextureArray> const& textureArray, unsigned int item,
    unsigned int level)
{
    if (!textureArray->GetData())
    {
        LogWarning("Texture array does not have system memory, creating it.");
        textureArray->CreateStorage();
    }

    DX11TextureArray* dxTextureArray = static_cast<DX11TextureArray*>(
        Bind(textureArray));
    unsigned int sri = textureArray->GetIndex(item, level);
    return dxTextureArray->CopyGpuToCpu(mImmediate, sri);
}

bool DX11Engine::GetNumActiveElements(
    std::shared_ptr<StructuredBuffer> const& buffer)
{
    DX11GraphicsObject* dxObject = Get(buffer);
    if (dxObject)
    {
        DX11StructuredBuffer* dxSBuffer =
            static_cast<DX11StructuredBuffer*>(dxObject);
        return dxSBuffer->GetNumActiveElements(mImmediate);
    }
    return false;
}

void DX11Engine::SetViewport(int x, int y, int w, int h)
{
    UINT numViewports = 1;
    mImmediate->RSGetViewports(&numViewports, &mViewport);
    LogAssert(1 == numViewports, "Failed to get viewport.");

    mViewport.TopLeftX = static_cast<float>(x);
    mViewport.TopLeftY = static_cast<float>(y);
    mViewport.Width = static_cast<float>(w);
    mViewport.Height = static_cast<float>(h);
    mImmediate->RSSetViewports(1, &mViewport);
}

void DX11Engine::GetViewport(int& x, int& y, int& w, int& h) const
{
    UINT numViewports = 1;
    D3D11_VIEWPORT viewport;
    mImmediate->RSGetViewports(&numViewports, &viewport);
    LogAssert(1 == numViewports, "Failed to get viewport.");

    x = static_cast<unsigned int>(viewport.TopLeftX);
    y = static_cast<unsigned int>(viewport.TopLeftY);
    w = static_cast<unsigned int>(viewport.Width);
    h = static_cast<unsigned int>(viewport.Height);
}

void DX11Engine::SetDepthRange(float zmin, float zmax)
{
    UINT numViewports = 1;
    mImmediate->RSGetViewports(&numViewports, &mViewport);
    LogAssert(1 == numViewports, "Failed to get viewport.");

    mViewport.MinDepth = zmin;
    mViewport.MaxDepth = zmax;
    mImmediate->RSSetViewports(1, &mViewport);
}

void DX11Engine::GetDepthRange(float& zmin, float& zmax) const
{
    UINT numViewports = 1;
    D3D11_VIEWPORT viewport;
    mImmediate->RSGetViewports(&numViewports, &viewport);
    LogAssert(1 == numViewports, "Failed to get viewport.");

    zmin = viewport.MinDepth;
    zmax = viewport.MaxDepth;
}

bool DX11Engine::Resize(unsigned int w, unsigned int h)
{
    // Release the previous back buffer before resizing.
    if (DestroyBackBuffer())
    {
        // Attempt to resize the back buffer to the incoming width and height.
        DXGI_SWAP_CHAIN_DESC desc;
        mSwapChain->GetDesc(&desc);
        HRESULT hr = mSwapChain->ResizeBuffers(desc.BufferCount, w, h,
            DXGI_FORMAT_R8G8B8A8_UNORM, 0);
        if (SUCCEEDED(hr))
        {
            // The attempt succeeded, so create new color and depth-stencil
            // objects.
            return CreateBackBuffer(w, h);
        }

        // The attempt to resize failed, so restore the back buffer to its
        // previous width and height.
        w = desc.BufferDesc.Width;
        h = desc.BufferDesc.Height;
        hr = mSwapChain->ResizeBuffers(desc.BufferCount, w, h,
            DXGI_FORMAT_R8G8B8A8_UNORM, 0);
        if (SUCCEEDED(hr))
        {
            return CreateBackBuffer(w, h);
        }
    }
    return false;
}

bool DX11Engine::IsFullscreen(IDXGIOutput* output) const
{
    if (mSwapChain)
    {
        if (output)
        {
            auto iter = mFullscreenState.find(output);
            if (iter != mFullscreenState.end())
            {
                return iter->second;
            }

            // The 'output' has not yet been passed to SetFullscreen, so it is
            // safe to assume that window is not fullscreen.
            return false;
        }

        LogError("Output parameter must be nonnull.");
        return false;
    }

    LogError("This function requires a swap chain.");
    return false;
}

bool DX11Engine::SetFullscreen(IDXGIOutput* output, bool fullscreen)
{
    if (mSwapChain)
    {
        if (output)
        {
            auto iter = mFullscreenState.find(output);
            if (iter == mFullscreenState.end())
            {
                // This is the first time 'output' has been seen, so insert it
                // into the map indicating that the window is not fullscreen.
                iter = mFullscreenState.insert(
                    std::make_pair(output,false)).first;
            }

            if (iter->second != fullscreen)
            {
                HRESULT hr;
                if (fullscreen)
                {
                    hr = mSwapChain->SetFullscreenState(TRUE, output);
                    if (SUCCEEDED(hr))
                    {
                        iter->second = true;
                        return true;
                    }
                    else
                    {
                        LogError("Failed to go fullscreen.");
                        return false;
                    }
                }
                else
                {
                    hr = mSwapChain->SetFullscreenState(FALSE, nullptr);
                    if (SUCCEEDED(hr))
                    {
                        iter->second = false;
                        return true;
                    }
                    else
                    {
                        LogError("Failed to go windowed.");
                        return false;
                    }
                }
            }
            else
            {
                // The requested state is the current state, so there is
                // nothing to do.
                return false;
            }
        }

        LogError("Output parameter must be nonnull.");
        return false;
    }

    LogError("This function requires a swap chain.");
    return false;
}

void DX11Engine::ClearColorBuffer()
{
    ID3D11RenderTargetView* rtViews[D3D11_SIMULTANEOUS_RENDER_TARGET_COUNT] =
        { nullptr };
    ID3D11DepthStencilView* dsView = nullptr;

    mImmediate->OMGetRenderTargets(mNumActiveRTs, rtViews, &dsView);
    SafeRelease(dsView);
    for (unsigned int i = 0; i < mNumActiveRTs; ++i)
    {
        if (rtViews[i])
        {
            mImmediate->ClearRenderTargetView(rtViews[i], &mClearColor[0]);
            rtViews[i]->Release();
        }
    }
}

void DX11Engine::ClearDepthBuffer()
{
    ID3D11DepthStencilView* dsView = nullptr;
    ID3D11RenderTargetView* rtView = nullptr;
    mImmediate->OMGetRenderTargets(1, &rtView, &dsView);
    SafeRelease(rtView);
    if (dsView)
    {
        mImmediate->ClearDepthStencilView(dsView, D3D11_CLEAR_DEPTH,
            mClearDepth, 0);
        dsView->Release();
    }
}

void DX11Engine::ClearStencilBuffer()
{
    ID3D11DepthStencilView* dsView = nullptr;
    ID3D11RenderTargetView* rtView = nullptr;
    mImmediate->OMGetRenderTargets(1, &rtView, &dsView);
    SafeRelease(rtView);
    if (dsView)
    {
        mImmediate->ClearDepthStencilView(dsView, D3D11_CLEAR_STENCIL, 0.0f,
            static_cast<UINT8>(mClearStencil));
        dsView->Release();
    }
}

void DX11Engine::ClearBuffers()
{
    ID3D11RenderTargetView* rtViews[D3D11_SIMULTANEOUS_RENDER_TARGET_COUNT] =
        { nullptr };
    ID3D11DepthStencilView* dsView = nullptr;

    mImmediate->OMGetRenderTargets(mNumActiveRTs, rtViews, &dsView);
    for (unsigned int i = 0; i < mNumActiveRTs; ++i)
    {
        if (rtViews[i])
        {
            mImmediate->ClearRenderTargetView(rtViews[i], &mClearColor[0]);
            rtViews[i]->Release();
        }
    }
    if (dsView)
    {
        mImmediate->ClearDepthStencilView(dsView,
            D3D11_CLEAR_DEPTH | D3D11_CLEAR_STENCIL, mClearDepth,
            static_cast<UINT8>(mClearStencil));
        dsView->Release();
    }
}

void DX11Engine::DisplayColorBuffer(unsigned int syncInterval)
{
    // The swap must occur on the thread in which the device was created.
    mSwapChain->Present(syncInterval, 0);
}

void DX11Engine::SetBlendState(std::shared_ptr<BlendState> const& state)
{
    if (state)
    {
        if (state != mActiveBlendState)
        {
            DX11BlendState* dxState =
                static_cast<DX11BlendState*>(Bind(state));
            if (dxState)
            {
                dxState->Enable(mImmediate);
                mActiveBlendState = state;
            }
            else
            {
                LogError("Failed to bind blend state.");
            }
        }
    }
    else
    {
        LogError("Input state is null.");
    }
}

void DX11Engine::SetDepthStencilState(
    std::shared_ptr<DepthStencilState> const& state)
{
    if (state)
    {
        if (state != mActiveDepthStencilState)
        {
            DX11DepthStencilState* dxState =
                static_cast<DX11DepthStencilState*>(Bind(state));
            if (dxState)
            {
                dxState->Enable(mImmediate);
                mActiveDepthStencilState = state;
            }
            else
            {
                LogError("Failed to bind depth-stencil state.");
            }
        }
    }
    else
    {
        LogError("Input state is null.");
    }
}

void DX11Engine::SetRasterizerState(
    std::shared_ptr<RasterizerState> const& state)
{
    if (state)
    {
        if (state != mActiveRasterizerState)
        {
            DX11RasterizerState* dxState =
                static_cast<DX11RasterizerState*>(Bind(state));
            if (dxState)
            {
                dxState->Enable(mImmediate);
                mActiveRasterizerState = state;
            }
            else
            {
                LogError("Failed to bind rasterizer state.");
            }
        }
    }
    else
    {
        LogError("Input state is null.");
    }
}

void DX11Engine::SetFont(std::shared_ptr<Font> const& font)
{
    if (font)
    {
        if (font != mActiveFont)
        {
            // Destroy font resources in GPU memory.  The mActiveFont should
            // be null once, only when the mDefaultFont is created.
            if (mActiveFont)
            {
                Unbind(mActiveFont->GetVertexBuffer());
                Unbind(mActiveFont->GetIndexBuffer());
                Unbind(mActiveFont->GetTextEffect()->GetTranslate());
                Unbind(mActiveFont->GetTextEffect()->GetColor());
                Unbind(mActiveFont->GetTextEffect()->GetVertexShader());
                Unbind(mActiveFont->GetTextEffect()->GetPixelShader());
            }

            mActiveFont = font;

            // Create font resources in GPU memory.
            Bind(mActiveFont->GetVertexBuffer());
            Bind(mActiveFont->GetIndexBuffer());
            Bind(mActiveFont->GetTextEffect()->GetTranslate());
            Bind(mActiveFont->GetTextEffect()->GetColor());
            Bind(mActiveFont->GetTextEffect()->GetVertexShader());
            Bind(mActiveFont->GetTextEffect()->GetPixelShader());
        }
    }
    else
    {
        LogError("Input font is null.");
    }
}

void DX11Engine::Enable(std::shared_ptr<DrawTarget> const& target)
{
    DX11DrawTarget* dxTarget = (DX11DrawTarget*)Bind(target);
    dxTarget->Enable(mImmediate);
    mNumActiveRTs = target->GetNumTargets();
}

void DX11Engine::Disable(std::shared_ptr<DrawTarget> const& target)
{
    DX11DrawTarget* dxTarget = (DX11DrawTarget*)Get(target);
    if (dxTarget)
    {
        dxTarget->Disable(mImmediate);
        mNumActiveRTs = 1;

        // The assumption is that Disable is called after you have written
        // the draw target outputs.  If the render targets want automatic
        // mipmap generation, we do so here.
        if (target->WantAutogenerateRTMipmaps())
        {
            unsigned int const numTargets = target->GetNumTargets();
            for (unsigned int i = 0; i < numTargets; ++i)
            {
                DX11Texture* dxTexture = static_cast<DX11Texture*>(
                    Get(target->GetRTTexture(i)));
                ID3D11ShaderResourceView* srView = dxTexture->GetSRView();
                if (srView)
                {
                    mImmediate->GenerateMips(dxTexture->GetSRView());
                }
            }
        }
    }
}

uint64_t DX11Engine::Draw(std::shared_ptr<Visual> const& visual)
{
    return Draw(visual.get());
}

uint64_t DX11Engine::Draw(Visual const* visual)
{
    if (visual)
    {
        auto const& vbuffer = visual->GetVertexBuffer();
        auto const& ibuffer = visual->GetIndexBuffer();
        auto const& effect = visual->GetEffect();
        if (vbuffer && ibuffer && effect)
        {
            return Draw(vbuffer, ibuffer, effect);
        }
    }

    LogError("Null input to Draw.");
    return 0;
}

uint64_t DX11Engine::Draw(
    std::shared_ptr<VertexBuffer> const& vbuffer,
    std::shared_ptr<IndexBuffer> const& ibuffer,
    std::shared_ptr<VisualEffect> const& effect)
{
    uint64_t numPixelsDrawn = 0;
    DX11VertexShader* dxVShader;
    DX11GeometryShader* dxGShader;
    DX11PixelShader* dxPShader;
    if (EnableShaders(effect, dxVShader, dxGShader, dxPShader))
    {
        // Enable the vertex buffer and input layout.
        DX11VertexBuffer* dxVBuffer = nullptr;
        DX11InputLayout* dxLayout = nullptr;
        if (vbuffer->IsFormatted())
        {
            dxVBuffer = static_cast<DX11VertexBuffer*>(Bind(vbuffer));
            dxLayout = mILMap.Bind(mDevice, vbuffer.get(),
                effect->GetVertexShader().get());
            dxVBuffer->Enable(mImmediate);
            dxLayout->Enable(mImmediate);
        }
        else
        {
            mImmediate->IASetInputLayout(nullptr);
        }

        // Enable the index buffer.
        DX11IndexBuffer* dxIBuffer = nullptr;
        if (ibuffer->IsIndexed())
        {
            dxIBuffer = static_cast<DX11IndexBuffer*>(Bind(ibuffer));
            dxIBuffer->Enable(mImmediate);
        }

        numPixelsDrawn = DrawPrimitive(vbuffer.get(), ibuffer.get());

        // Disable the vertex buffer and input layout.
        if (vbuffer->IsFormatted())
        {
            dxVBuffer->Disable(mImmediate);
            dxLayout->Disable(mImmediate);
        }

        // Disable the index buffer.
        if (dxIBuffer)
        {
            dxIBuffer->Disable(mImmediate);
        }

        DisableShaders(effect, dxVShader, dxGShader, dxPShader);
    }
    return numPixelsDrawn;
}

uint64_t DX11Engine::Draw(int x, int y, Vector4<float> const& color,
    std::string const& message)
{
    uint64_t numPixelsDrawn;

    if (message.length() > 0)
    {
        int vx, vy, vw, vh;
        GetViewport(vx, vy, vw, vh);
        mActiveFont->Typeset(vw, vh, x, y, color, message);
        
        Update(mActiveFont->GetTextEffect()->GetTranslate());
        Update(mActiveFont->GetTextEffect()->GetColor());
        Update(mActiveFont->GetVertexBuffer());

        // We need to restore default state for text drawing.  Remember the
        // current state so that we can reset it after drawing.
        std::shared_ptr<BlendState> bState = GetBlendState();
        std::shared_ptr<DepthStencilState> dState = GetDepthStencilState();
        std::shared_ptr<RasterizerState> rState = GetRasterizerState();
        SetDefaultBlendState();
        SetDefaultDepthStencilState();
        SetDefaultRasterizerState();

        numPixelsDrawn = Draw(mActiveFont->GetVertexBuffer(),
            mActiveFont->GetIndexBuffer(), mActiveFont->GetTextEffect());

        SetBlendState(bState);
        SetDepthStencilState(dState);
        SetRasterizerState(rState);
    }
    else
    {
        numPixelsDrawn = 0;
    }

    return numPixelsDrawn;
}

uint64_t DX11Engine::Draw(std::shared_ptr<OverlayEffect> const& overlay)
{
    if (overlay)
    {
        auto const& vbuffer = overlay->GetVertexBuffer();
        auto const& ibuffer = overlay->GetIndexBuffer();
        auto const& effect =  overlay->GetEffect();
        if (vbuffer && ibuffer && effect)
        {
            return Draw(vbuffer, ibuffer, effect);
        }
    }

    LogError("Null input to Draw.");
    return 0;
}

uint64_t DX11Engine::DrawPrimitive(VertexBuffer const* vbuffer,
    IndexBuffer const* ibuffer)
{
    UINT numActiveVertices = vbuffer->GetNumActiveElements();
    UINT vertexOffset = vbuffer->GetOffset();

    UINT numActiveIndices = ibuffer->GetNumActiveIndices();
    UINT firstIndex = ibuffer->GetFirstIndex();
    IPType type = ibuffer->GetPrimitiveType();

    D3D11_PRIMITIVE_TOPOLOGY topology =
        msPrimitiveType[Log2OfPowerOfTwo((int)type)];
    mImmediate->IASetPrimitiveTopology(topology);

    ID3D11Query* occlusionQuery = nullptr;
    uint64_t numPixelsDrawn = 0;
    if (mAllowOcclusionQuery)
    {
        occlusionQuery = BeginOcclusionQuery();
    }

    if (ibuffer->IsIndexed())
    {
        if (numActiveIndices > 0)
        {
            mImmediate->DrawIndexed(numActiveIndices,
                firstIndex, vertexOffset);
        }
    }
    else
    {
        if (numActiveVertices > 0)
        {
            mImmediate->Draw(numActiveVertices, vertexOffset);
        }
    }

    if (mAllowOcclusionQuery)
    {
        numPixelsDrawn = EndOcclusionQuery(occlusionQuery);
    }

    return numPixelsDrawn;
}

ID3D11Query* DX11Engine::BeginOcclusionQuery()
{
    D3D11_QUERY_DESC desc;
    desc.Query = D3D11_QUERY_OCCLUSION;
    desc.MiscFlags = D3D11_QUERY_MISC_NONE;
    ID3D11Query* occlusionQuery = nullptr;
    HRESULT hr = mDevice->CreateQuery(&desc, &occlusionQuery);
    if (SUCCEEDED(hr))
    {
        mImmediate->Begin(occlusionQuery);
        return occlusionQuery;
    }

    LogError("CreateQuery failed.");
    return nullptr;
}

uint64_t DX11Engine::EndOcclusionQuery(ID3D11Query* occlusionQuery)
{
    if (occlusionQuery)
    {
        mImmediate->End(occlusionQuery);
        UINT64 data = 0;
        UINT size = sizeof(UINT64);
        while (S_OK != mImmediate->GetData(occlusionQuery, &data, size, 0))
        {
            // Wait for end of query.
        }
        occlusionQuery->Release();
        return data;
    }

    LogError("No query provided.");
    return 0;
}

void DX11Engine::Execute(std::shared_ptr<ComputeShader> const& cshader,
    unsigned int numXGroups, unsigned int numYGroups, unsigned int numZGroups)
{
    if (cshader && numXGroups > 0 && numYGroups > 0 && numZGroups > 0)
    {
        DX11ComputeShader* dxCShader =
            static_cast<DX11ComputeShader*>(Bind(cshader));
        Enable(cshader.get(), dxCShader);
        mImmediate->Dispatch(numXGroups, numYGroups, numZGroups);
        Disable(cshader.get(), dxCShader);
    }
    else
    {
        LogError("Invalid input parameter.");
    }
}

void DX11Engine::WaitForFinish()
{
    D3D11_QUERY_DESC desc;
    desc.Query = D3D11_QUERY_EVENT;
    desc.MiscFlags = D3D11_QUERY_MISC_NONE;
    ID3D11Query* query = nullptr;
    HRESULT hr = mDevice->CreateQuery(&desc, &query);
    CHECK_HR_RETURN_NONE("CreateQuery failed in WaitForFinish");

    mImmediate->End(query);
    BOOL data = 0;
    UINT size = sizeof(BOOL);
    while (S_OK != mImmediate->GetData(query, &data, size, 0))
    {
        // Wait for end of query.
    }
    query->Release();
}

void DX11Engine::BeginTimer(DX11PerformanceCounter& counter)
{
    if (counter.mFrequencyQuery)
    {
        mImmediate->Begin(counter.mFrequencyQuery);

        mImmediate->End(counter.mStartTimeQuery);
        while (S_OK != mImmediate->GetData(counter.mStartTimeQuery,
            &counter.mStartTime, sizeof(counter.mStartTime), 0))
        {
            // Wait for end of query.
        }
    }
}

void DX11Engine::EndTimer(DX11PerformanceCounter& counter)
{
    if (counter.mFrequencyQuery)
    {
        mImmediate->End(counter.mFinalTimeQuery);
        while (S_OK != mImmediate->GetData(counter.mFinalTimeQuery,
            &counter.mFinalTime, sizeof(counter.mFinalTime), 0))
        {
            // Wait for end of query.
        }

        mImmediate->End(counter.mFrequencyQuery);
        while (S_OK != mImmediate->GetData(counter.mFrequencyQuery,
            &counter.mTimeStamp, sizeof(counter.mTimeStamp), 0))
        {
            // Wait for end of query.
        }
    }
}

bool DX11Engine::EnableShaders(std::shared_ptr<VisualEffect> const& effect,
    DX11VertexShader*& dxVShader, DX11GeometryShader*& dxGShader,
    DX11PixelShader*& dxPShader)
{
    dxVShader = nullptr;
    dxGShader = nullptr;
    dxPShader = nullptr;

    // Get the active vertex shader.
    if (!effect->GetVertexShader())
    {
        LogError("Effect does not have a vertex shader.");
        return false;
    }
    dxVShader = static_cast<DX11VertexShader*>(
        Bind(effect->GetVertexShader()));

    // Get the active geometry shader (if any).
    if (effect->GetGeometryShader())
    {
        dxGShader = static_cast<DX11GeometryShader*>(
            Bind(effect->GetGeometryShader()));
    }

    // Get the active pixel shader.
    if (!effect->GetPixelShader())
    {
        LogError("Effect does not have a pixel shader.");
        return false;
    }
    dxPShader = static_cast<DX11PixelShader*>(
        Bind(effect->GetPixelShader()));

    // Enable the shaders and resources.
    Enable(effect->GetVertexShader().get(), dxVShader);
    Enable(effect->GetPixelShader().get(), dxPShader);
    if (dxGShader)
    {
        Enable(effect->GetGeometryShader().get(), dxGShader);
    }

    return true;
}

void DX11Engine::DisableShaders(std::shared_ptr<VisualEffect> const& effect,
    DX11VertexShader* dxVShader, DX11GeometryShader* dxGShader,
    DX11PixelShader* dxPShader)
{
    if (dxGShader)
    {
        Disable(effect->GetGeometryShader().get(), dxGShader);
    }
    Disable(effect->GetPixelShader().get(), dxPShader);
    Disable(effect->GetVertexShader().get(), dxVShader);
}

void DX11Engine::Enable(Shader const* shader, DX11Shader* dxShader)
{
    dxShader->Enable(mImmediate);
    EnableCBuffers(shader, dxShader);
    EnableTBuffers(shader, dxShader);
    EnableSBuffers(shader, dxShader);
    EnableRBuffers(shader, dxShader);
    EnableTextures(shader, dxShader);
    EnableTextureArrays(shader, dxShader);
    EnableSamplers(shader, dxShader);
}

void DX11Engine::Disable(Shader const* shader, DX11Shader* dxShader)
{
    DisableSamplers(shader, dxShader);
    DisableTextureArrays(shader, dxShader);
    DisableTextures(shader, dxShader);
    DisableRBuffers(shader, dxShader);
    DisableSBuffers(shader, dxShader);
    DisableTBuffers(shader, dxShader);
    DisableCBuffers(shader, dxShader);
    dxShader->Disable(mImmediate);
}

void DX11Engine::EnableCBuffers(Shader const* shader, DX11Shader* dxShader)
{
    int const index = ConstantBuffer::shaderDataLookup;
    for (auto const& cb : shader->GetData(index))
    {
        if (cb.object)
        {
            DX11ConstantBuffer* dxCB =
                static_cast<DX11ConstantBuffer*>(Bind(cb.object));
            if (dxCB)
            {
                dxShader->EnableCBuffer(mImmediate, cb.bindPoint,
                    dxCB->GetDXBuffer());
            }
            else
            {
                LogError("Failed to bind constant buffer.");
            }
        }
        else
        {
            LogError(cb.name + " is null constant buffer.");
        }
    }
}

void DX11Engine::DisableCBuffers(Shader const* shader, DX11Shader* dxShader)
{
    int const index = ConstantBuffer::shaderDataLookup;
    for (auto const& cb : shader->GetData(index))
    {
        dxShader->DisableCBuffer(mImmediate, cb.bindPoint);
    }
}

void DX11Engine::EnableTBuffers(Shader const* shader, DX11Shader* dxShader)
{
    int const index = TextureBuffer::shaderDataLookup;
    for (auto const& tb : shader->GetData(index))
    {
        if (tb.object)
        {
            DX11TextureBuffer* dxTB =
                static_cast<DX11TextureBuffer*>(Bind(tb.object));
            if (dxTB)
            {
                dxShader->EnableSRView(mImmediate, tb.bindPoint,
                    dxTB->GetSRView());
            }
            else
            {
                LogError("Failed to bind texture buffer.");
            }
        }
        else
        {
            LogError(tb.name + " is null texture buffer.");
        }
    }
}

void DX11Engine::DisableTBuffers(Shader const* shader, DX11Shader* dxShader)
{
    int const index = TextureBuffer::shaderDataLookup;
    for (auto const& tb : shader->GetData(index))
    {
        dxShader->DisableSRView(mImmediate, tb.bindPoint);
    }
}

void DX11Engine::EnableSBuffers(Shader const* shader, DX11Shader* dxShader)
{
    int const index = StructuredBuffer::shaderDataLookup;
    for (auto const& sb : shader->GetData(index))
    {
        if (sb.object)
        {
            DX11StructuredBuffer* dxSB =
                static_cast<DX11StructuredBuffer*>(Bind(sb.object));
            if (dxSB)
            {
                if (sb.isGpuWritable)
                {
                    StructuredBuffer* gtSB =
                        static_cast<StructuredBuffer*>(sb.object.get());

                    unsigned int numActive = (gtSB->GetKeepInternalCount() ?
                        0xFFFFFFFFu : gtSB->GetNumActiveElements());
                    dxShader->EnableUAView(mImmediate, sb.bindPoint,
                        dxSB->GetUAView(), numActive);
                }
                else
                {
                    dxShader->EnableSRView(mImmediate, sb.bindPoint,
                        dxSB->GetSRView());
                }
            }
            else
            {
                LogError("Failed to bind structured buffer.");
            }
        }
        else
        {
            LogError(sb.name + " is null structured buffer.");
        }
    }
}

void DX11Engine::DisableSBuffers(Shader const* shader, DX11Shader* dxShader)
{
    int const index = StructuredBuffer::shaderDataLookup;
    for (auto const& sb : shader->GetData(index))
    {
        if (sb.isGpuWritable)
        {
            dxShader->DisableUAView(mImmediate, sb.bindPoint);
        }
        else
        {
            dxShader->DisableSRView(mImmediate, sb.bindPoint);
        }
    }
}

void DX11Engine::EnableRBuffers(Shader const* shader, DX11Shader* dxShader)
{
    int const index = RawBuffer::shaderDataLookup;
    for (auto const& rb : shader->GetData(index))
    {
        if (rb.object)
        {
            DX11RawBuffer* dxRB =
                static_cast<DX11RawBuffer*>(Bind(rb.object));
            if (dxRB)
            {
                if (rb.isGpuWritable)
                {
                    dxShader->EnableUAView(mImmediate, rb.bindPoint,
                        dxRB->GetUAView(), 0xFFFFFFFFu);
                }
                else
                {
                    dxShader->EnableSRView(mImmediate, rb.bindPoint,
                        dxRB->GetSRView());
                }
            }
            else
            {
                LogError("Failed to bind byte-address buffer.");
            }
        }
        else
        {
            LogError(rb.name + " is null byte-address buffer.");
        }
    }
}

void DX11Engine::DisableRBuffers(Shader const* shader, DX11Shader* dxShader)
{
    int const index = RawBuffer::shaderDataLookup;
    for (auto const& rb : shader->GetData(index))
    {
        if (rb.isGpuWritable)
        {
            dxShader->DisableUAView(mImmediate, rb.bindPoint);
        }
        else
        {
            dxShader->DisableSRView(mImmediate, rb.bindPoint);
        }
    }
}

void DX11Engine::EnableTextures(Shader const* shader, DX11Shader* dxShader)
{
    int const index = TextureSingle::shaderDataLookup;
    for (auto const& tx : shader->GetData(index))
    {
        if (tx.object)
        {
            DX11TextureSingle* dxTX =
                static_cast<DX11TextureSingle*>(Bind(tx.object));
            if (dxTX)
            {
                if (tx.isGpuWritable)
                {
                    dxShader->EnableUAView(mImmediate, tx.bindPoint,
                        dxTX->GetUAView(), 0xFFFFFFFFu);
                }
                else
                {
                    dxShader->EnableSRView(mImmediate, tx.bindPoint,
                        dxTX->GetSRView());
                }
            }
            else
            {
                LogError("Failed to bind texture.");
            }
        }
        else
        {
            LogError(tx.name + " is null texture.");
        }
    }
}

void DX11Engine::DisableTextures(Shader const* shader, DX11Shader* dxShader)
{
    int const index = TextureSingle::shaderDataLookup;
    for (auto const& tx : shader->GetData(index))
    {
        if (tx.isGpuWritable)
        {
            dxShader->DisableUAView(mImmediate, tx.bindPoint);
        }
        else
        {
            dxShader->DisableSRView(mImmediate, tx.bindPoint);
        }
    }
}

void DX11Engine::EnableTextureArrays(Shader const* shader,
    DX11Shader* dxShader)
{
    int const index = TextureArray::shaderDataLookup;
    for (auto const& ta : shader->GetData(index))
    {
        if (ta.object)
        {
            DX11TextureArray* dxTA =
                static_cast<DX11TextureArray*>(Bind(ta.object));
            if (dxTA)
            {
                if (ta.isGpuWritable)
                {
                    dxShader->EnableUAView(mImmediate, ta.bindPoint,
                        dxTA->GetUAView(), 0xFFFFFFFFu);
                }
                else
                {
                    dxShader->EnableSRView(mImmediate, ta.bindPoint,
                        dxTA->GetSRView());
                }
            }
            else
            {
                LogError("Failed to bind texture array.");
            }
        }
        else
        {
            LogError(ta.name + " is null texture array.");
        }
    }
}

void DX11Engine::DisableTextureArrays(Shader const* shader,
    DX11Shader* dxShader)
{
    int const index = TextureArray::shaderDataLookup;
    for (auto const& ta : shader->GetData(index))
    {
        if (ta.isGpuWritable)
        {
            dxShader->DisableUAView(mImmediate, ta.bindPoint);
        }
        else
        {
            dxShader->DisableSRView(mImmediate, ta.bindPoint);
        }
    }
}

void DX11Engine::EnableSamplers(Shader const* shader, DX11Shader* dxShader)
{
    int const index = SamplerState::shaderDataLookup;
    for (auto const& ss : shader->GetData(index))
    {
        if (ss.object)
        {
            DX11SamplerState* dxSS =
                static_cast<DX11SamplerState*>(Bind(ss.object));
            if (dxSS)
            {
                dxShader->EnableSampler(mImmediate, ss.bindPoint,
                    dxSS->GetDXSamplerState());
            }
            else
            {
                LogError("Failed to bind sampler state.");
            }
        }
        else
        {
            LogError(ss.name + " is null sampler state.");
        }
    }
}

void DX11Engine::DisableSamplers(Shader const* shader, DX11Shader* dxShader)
{
    int const index = SamplerState::shaderDataLookup;
    for (auto const& ss : shader->GetData(index))
    {
        dxShader->DisableSampler(mImmediate, ss.bindPoint);
    }
}

DX11Engine::GOListener::~GOListener()
{
}

DX11Engine::GOListener::GOListener(DX11Engine* engine)
    :
    mEngine(engine)
{
}

void DX11Engine::GOListener::OnDestroy(GraphicsObject const* object)
{
    if (mEngine)
    {
        mEngine->Unbind(object);
    }
}

DX11Engine::DTListener::~DTListener()
{
}

DX11Engine::DTListener::DTListener(DX11Engine* engine)
    :
    mEngine(engine)
{
}

void DX11Engine::DTListener::OnDestroy(DrawTarget const* target)
{
    if (mEngine)
    {
        mEngine->Unbind(target);
    }
}


// Factory creation for bridge building in Bind(...).
DX11Engine::CreateFunction const DX11Engine::msCreateFunctions[GT_NUM_TYPES] =
{
    nullptr,    // GT_GRAPHICS_OBJECT (abstract base)
    nullptr,    // GT_RESOURCE (abstract base)
    nullptr,    // GT_BUFFER (abstract base)
    &DX11ConstantBuffer::Create,
    &DX11TextureBuffer::Create,
    &DX11VertexBuffer::Create,
    &DX11IndexBuffer::Create,
    &DX11StructuredBuffer::Create,
    nullptr,  // TODO:  Implement TypedBuffer
    &DX11RawBuffer::Create,
    &DX11IndirectArgumentsBuffer::Create,
    nullptr,    // GT_TEXTURE (abstract base)
    nullptr,    // GT_TEXTURE_SINGLE (abstract base)
    &DX11Texture1::Create,
    &DX11Texture2::Create,
    &DX11TextureRT::Create,
    &DX11TextureDS::Create,
    &DX11Texture3::Create,
    nullptr,  // GT_TEXTURE_ARRAY (abstract base)
    &DX11Texture1Array::Create,
    &DX11Texture2Array::Create,
    &DX11TextureCube::Create,
    &DX11TextureCubeArray::Create,
    nullptr,    // GT_SHADER (abstract base)
    &DX11VertexShader::Create,
    &DX11GeometryShader::Create,
    &DX11PixelShader::Create,
    &DX11ComputeShader::Create,
    nullptr,    // GT_DRAWING_STATE (abstract base)
    &DX11SamplerState::Create,
    &DX11BlendState::Create,
    &DX11DepthStencilState::Create,
    &DX11RasterizerState::Create
};

// Conversions from GTEngine values to DX11 values.  Lookups by Log2(IP_*).
D3D11_PRIMITIVE_TOPOLOGY const DX11Engine::msPrimitiveType[IP_NUM_TYPES] =
{
    D3D11_PRIMITIVE_TOPOLOGY_POINTLIST,     // IP_POLYPOINT
    D3D11_PRIMITIVE_TOPOLOGY_LINELIST,      // IP_POLYSEGMENT_DISJOINT
    D3D11_PRIMITIVE_TOPOLOGY_LINESTRIP,     // IP_POLYSEGMENT_CONTIGUOUS
    D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST,  // IP_TRIMESH
    D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP  // IP_TRISTRIP
};
