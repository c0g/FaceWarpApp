// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <Graphics/DX11/GteDX11DepthStencilState.h>
using namespace gte;


DX11DepthStencilState::~DX11DepthStencilState()
{
}

DX11DepthStencilState::DX11DepthStencilState(ID3D11Device* device,
    DepthStencilState const* depthStencilState)
    :
    DX11DrawingState(depthStencilState)
{
    // Specify the rasterizer state description.
    D3D11_DEPTH_STENCIL_DESC desc;
    desc.DepthEnable = (depthStencilState->depthEnable ? TRUE : FALSE);
    desc.DepthWriteMask = msWriteMask[depthStencilState->writeMask];
    desc.DepthFunc = msComparison[depthStencilState->comparison];
    desc.StencilEnable = (depthStencilState->stencilEnable ? TRUE : FALSE);
    desc.StencilReadMask = depthStencilState->stencilReadMask;
    desc.StencilWriteMask = depthStencilState->stencilWriteMask;
    DepthStencilState::Face front = depthStencilState->frontFace;
    desc.FrontFace.StencilFailOp = msOperation[front.fail];
    desc.FrontFace.StencilDepthFailOp = msOperation[front.depthFail];
    desc.FrontFace.StencilPassOp = msOperation[front.pass];
    desc.FrontFace.StencilFunc = msComparison[front.comparison];
    DepthStencilState::Face back = depthStencilState->backFace;
    desc.BackFace.StencilFailOp = msOperation[back.fail];
    desc.BackFace.StencilDepthFailOp = msOperation[back.depthFail];
    desc.BackFace.StencilPassOp = msOperation[back.pass];
    desc.BackFace.StencilFunc = msComparison[back.comparison];

    // Create the depth-stencil state.
    ID3D11DepthStencilState* state = nullptr;
    HRESULT hr = device->CreateDepthStencilState(&desc, &state);
    CHECK_HR_RETURN_NONE("Failed to create depth-stencil state");
    mDXObject = state;
}

DX11GraphicsObject* DX11DepthStencilState::Create(ID3D11Device* device,
    GraphicsObject const* object)
{
    if (object->GetType() == GT_DEPTH_STENCIL_STATE)
    {
        return new DX11DepthStencilState(device,
            static_cast<DepthStencilState const*>(object));
    }

    LogError("Invalid object type.");
    return nullptr;
}

DepthStencilState* DX11DepthStencilState::GetDepthStencilState()
{
    return static_cast<DepthStencilState*>(mGTObject);
}

ID3D11DepthStencilState* DX11DepthStencilState::GetDXDepthStencilState()
{
    return static_cast<ID3D11DepthStencilState*>(mDXObject);
}

void DX11DepthStencilState::Enable(ID3D11DeviceContext* context)
{
    DepthStencilState* dsState = GetDepthStencilState();
    context->OMSetDepthStencilState(GetDXDepthStencilState(),
        dsState->reference);
}


D3D11_DEPTH_WRITE_MASK const DX11DepthStencilState::msWriteMask[] =
{
    D3D11_DEPTH_WRITE_MASK_ZERO,
    D3D11_DEPTH_WRITE_MASK_ALL
};

D3D11_COMPARISON_FUNC const DX11DepthStencilState::msComparison[] =
{
    D3D11_COMPARISON_NEVER,
    D3D11_COMPARISON_LESS,
    D3D11_COMPARISON_EQUAL,
    D3D11_COMPARISON_LESS_EQUAL,
    D3D11_COMPARISON_GREATER,
    D3D11_COMPARISON_NOT_EQUAL,
    D3D11_COMPARISON_GREATER_EQUAL,
    D3D11_COMPARISON_ALWAYS
};

D3D11_STENCIL_OP const DX11DepthStencilState::msOperation[] =
{
    D3D11_STENCIL_OP_KEEP,
    D3D11_STENCIL_OP_ZERO,
    D3D11_STENCIL_OP_REPLACE,
    D3D11_STENCIL_OP_INCR_SAT,
    D3D11_STENCIL_OP_DECR_SAT,
    D3D11_STENCIL_OP_INVERT,
    D3D11_STENCIL_OP_INCR,
    D3D11_STENCIL_OP_DECR
};
