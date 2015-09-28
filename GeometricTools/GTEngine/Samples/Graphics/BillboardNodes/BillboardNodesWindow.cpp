// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include "BillboardNodesWindow.h"


BillboardNodesWindow::BillboardNodesWindow(Parameters& parameters)
    :
    Window3(parameters)
{
    if (!SetEnvironment())
    {
        parameters.created = false;
        return;
    }

    mEngine->SetClearColor({0.9f, 0.9f, 0.9f, 1.0f});

    InitializeCamera();
    CreateScene();
    mCameraRig.UpdatePVWMatrices();
    mCuller.ComputeVisibleSet(mCamera, mScene);
}

void BillboardNodesWindow::OnIdle()
{
    mTimer.Measure();

    if (mCameraRig.Move())
    {
        mCuller.ComputeVisibleSet(mCamera, mScene);
    }

    mEngine->ClearBuffers();
    VisibleSet const& vset = mCuller.GetVisibleSet();
    for (int i = 0; i < vset.GetNumVisible(); ++i)
    {
        mEngine->Draw(vset.Get(i));
    }

#if defined(DEMONSTRATE_VIEWPORT_BOUNDING_RECTANGLE)
    ComputeTorusBoundingRectangle();
    mEngine->SetBlendState(mBlendState);
    std::shared_ptr<RasterizerState> rstate = mEngine->GetRasterizerState();
    mEngine->SetRasterizerState(mNoCullState);
    mEngine->Draw(mOverlay);
    mEngine->SetRasterizerState(rstate);
    mEngine->SetDefaultBlendState();
#endif

    mEngine->Draw(8, mYSize - 8, { 1.0f, 1.0f, 1.0f, 1.0f }, mTimer.GetFPS());
    mEngine->DisplayColorBuffer(0);

    mTimer.UpdateFrameCount();
}

bool BillboardNodesWindow::OnCharPress(unsigned char key, int x, int y)
{
    switch (key)
    {
    case 'p':
    case 'P':
        if (mEngine->GetRasterizerState() != mCullCWState)
        {
            Matrix4x4<float> xReflect = Matrix4x4<float>::Identity();
            xReflect(0, 0) = -1.0f;
            mCamera->SetPostProjectionMatrix(xReflect);
            mEngine->SetRasterizerState(mCullCWState);
        }
        else
        {
            mCamera->SetPostProjectionMatrix(Matrix4x4<float>::Identity());
            mEngine->SetDefaultRasterizerState();
        }
        mCameraRig.UpdatePVWMatrices();
        return true;
    }
    return Window::OnCharPress(key, x, y);
}

bool BillboardNodesWindow::OnMouseMotion(MouseButton button, int x, int y,
    unsigned int modifiers)
{
    if (Window3::OnMouseMotion(button, x, y, modifiers))
    {
        mCuller.ComputeVisibleSet(mCamera, mScene);
    }
    return true;
}

bool BillboardNodesWindow::SetEnvironment()
{
    std::string path = mEnvironment.GetVariable("GTE_PATH");
    if (path == "")
    {
        LogError("You must create the environment variable GTE_PATH.");
        return false;
    }
    mEnvironment.Insert(path + "/Samples/Data/");

    if (mEnvironment.GetPath("BlueGrid.png") == "")
    {
        LogError("Cannot find file BlueGrid.png.");
        return false;
    }

    if (mEnvironment.GetPath("RedSky.png") == "")
    {
        LogError("Cannot find file RedSky.png.");
        return false;
    }

    return true;
}

void BillboardNodesWindow::CreateScene()
{
    mScene = std::make_shared<Node>();

    std::string path = mEnvironment.GetPath("BlueGrid.png");
    mGroundTexture.reset(WICFileIO::Load(path, true));
    mGroundTexture->AutogenerateMipmaps();

    path = mEnvironment.GetPath("RedSky.png");
    mSkyTexture.reset(WICFileIO::Load(path, false));

    VertexFormat vformat;
    vformat.Bind(VA_POSITION, DF_R32G32B32_FLOAT, 0);
    vformat.Bind(VA_TEXCOORD, DF_R32G32_FLOAT, 0);

    MeshFactory mf;
    mf.SetVertexFormat(vformat);

    // Create the ground.  It covers a square with vertices (1,1,0), (1,-1,0),
    // (-1,1,0), and (-1,-1,0).  Multiply the texture coordinates by a factor
    // to enhance the wrap-around.
    mGround = mf.CreateRectangle(2, 2, 16.0f, 16.0f);
    mScene->AttachChild(mGround);
    std::shared_ptr<VertexBuffer> vbuffer = mGround->GetVertexBuffer();
    unsigned int numVertices = vbuffer->GetNumElements();
    Vertex* vertex = vbuffer->Get<Vertex>();
    for (unsigned int i = 0; i < numVertices; ++i)
    {
        vertex[i].tcoord *= 128.0f;
    }

    // Create a texture effect for the ground.
    std::shared_ptr<Texture2Effect> groundEffect =
        std::make_shared<Texture2Effect>(mProgramFactory, mGroundTexture,
        SamplerState::MIN_L_MAG_L_MIP_L, SamplerState::WRAP,
        SamplerState::WRAP);
    mGround->SetEffect(groundEffect);

    // Create a rectangle mesh.  The mesh is in the xy-plane.  Do not apply
    // local transformations to the mesh.  Use the billboard node transforms
    // to control the mesh location and orientation.
    mRectangle = mf.CreateRectangle(2, 2, 0.125f, 0.25f);

    // Create a texture effect for the rectangle.
    std::shared_ptr<Texture2Effect> rectEffect =
        std::make_shared<Texture2Effect>(mProgramFactory, mSkyTexture,
        SamplerState::MIN_L_MAG_L_MIP_P, SamplerState::CLAMP,
        SamplerState::CLAMP);
    mRectangle->SetEffect(rectEffect);

    // Create a torus mesh.  Do not apply local transformations to the mesh.
    // Use the billboard node transforms to control the mesh location and
    // orientation.
    mTorus = mf.CreateTorus(16, 16, 1.0f, 0.25f);
    mTorus->localTransform.SetUniformScale(0.1f);

    // Create a texture effect for the torus.
    std::shared_ptr<Texture2Effect> torusEffect =
        std::make_shared<Texture2Effect>(mProgramFactory, mSkyTexture,
        SamplerState::MIN_L_MAG_L_MIP_P, SamplerState::CLAMP,
        SamplerState::CLAMP);
    mTorus->SetEffect(torusEffect);

    // Create a billboard node that causes a rectangle always to be facing the
    // camera.  This is the type of billboard for an avatar.
    mBillboard0 = std::make_shared<BillboardNode>(mCamera);
    mBillboard0->AttachChild(mRectangle);
    mScene->AttachChild(mBillboard0);

    // The billboard rotation is about its model-space up-vector (0,1,0).  In
    // this application, world-space up is (0,0,1).  Locally rotate the
    // billboard so it's up-vector matches the world's.
    AxisAngle<4, float> aa(Vector4<float>::Unit(0), (float)GTE_C_HALF_PI);
    mBillboard0->localTransform.SetTranslation(-0.25f, 0.0f, 0.25f);
    mBillboard0->localTransform.SetRotation(aa);

    // Create a billboard node that causes the torus always to be oriented the
    // same way relative to the camera.
    mBillboard1 = std::make_shared<BillboardNode>(mCamera);
    mBillboard1->AttachChild(mTorus);
    mScene->AttachChild(mBillboard1);

    // The billboard rotation is about its model-space up-vector (0,1,0).  In
    // this application, world-space up is (0,0,1).  Locally rotate the
    // billboard so it's up-vector matches the world's.
    mBillboard1->localTransform.SetTranslation(0.25f, 0.0f, 0.25f);
    mBillboard1->localTransform.SetRotation(aa);

    // When the trackball moves, automatically update the PVW matrices that
    // are used by the effects.
    mCameraRig.Subscribe(mGround->worldTransform,
        groundEffect->GetPVWMatrixConstant());
    mCameraRig.Subscribe(mRectangle->worldTransform,
        rectEffect->GetPVWMatrixConstant());
    mCameraRig.Subscribe(mTorus->worldTransform,
        torusEffect->GetPVWMatrixConstant());

    // Attach the scene to the virtual trackball.  When the trackball moves,
    // the W matrix of the scene is updated automatically.  The W matrices
    // of the child objects are also updated by the hierarchical update.
    mTrackball.Attach(mScene);
    mTrackball.Update();

#if defined(DEMONSTRATE_VIEWPORT_BOUNDING_RECTANGLE)
    mBlendState = std::make_shared<BlendState>();
    mBlendState->target[0].enable = true;
    mBlendState->target[0].srcColor = BlendState::BM_SRC_ALPHA;
    mBlendState->target[0].dstColor = BlendState::BM_INV_SRC_ALPHA;
    mBlendState->target[0].srcAlpha = BlendState::BM_SRC_ALPHA;
    mBlendState->target[0].dstAlpha = BlendState::BM_INV_SRC_ALPHA;

    mOverlay = std::make_shared<OverlayEffect>(mProgramFactory, mXSize,
        mYSize, 1, 1, SamplerState::MIN_P_MAG_P_MIP_P, SamplerState::CLAMP,
        SamplerState::CLAMP, true);
    std::shared_ptr<Texture2> overlayTexture = std::make_shared<Texture2>(
        DF_R8G8B8A8_UNORM, 1, 1);
    mOverlay->SetTexture(overlayTexture);
    unsigned int& texel = *overlayTexture->Get<unsigned int>();
    texel = 0x400000FF;  // (r,g,b,a) = (0,0,255,64)

    mNoCullState = std::make_shared<RasterizerState>();
    mNoCullState->cullMode = RasterizerState::CULL_NONE;
#endif

#if defined(DEMONSTRATE_POST_PROJECTION_REFLECTION)
    mCullCWState = std::make_shared<RasterizerState>();
    mCullCWState->cullMode = RasterizerState::CULL_FRONT;
#endif
}

void BillboardNodesWindow::InitializeCamera()
{
    mCamera->SetFrustum(60.0f, GetAspectRatio(), 0.1f, 100.0f);
    Vector4<float> camPosition{ 0.0f, -1.0f, 0.25f, 1.0f };
    Vector4<float> camDVector{ 0.0f, 1.0f, 0.0f, 0.0f };
    Vector4<float> camUVector{ 0.0f, 0.0f, 1.0f, 0.0f };
    Vector4<float> camRVector = Cross(camDVector, camUVector);
    mCamera->SetFrame(camPosition, camDVector, camUVector, camRVector);

    mTranslationSpeed = 0.005f;
    mRotationSpeed = 0.002f;
    mTranslationSpeedFactor = 2.0f;
    mRotationSpeedFactor = 2.0f;
    mCameraRig.SetTranslationSpeed(mTranslationSpeed);
    mCameraRig.SetRotationSpeed(mRotationSpeed);
    mCameraRig.ComputeWorldAxes();
}

#if defined(DEMONSTRATE_VIEWPORT_BOUNDING_RECTANGLE)

void BillboardNodesWindow::ComputeTorusBoundingRectangle()
{
    Matrix4x4<float> pvMatrix = mCamera->GetProjectionViewMatrix();
#if defined(GTE_USE_MAT_VEC)
    Matrix4x4<float> pvwMatrix = pvMatrix * mTorus->worldTransform;
#else
    Matrix4x4<float> pvwMatrix = mTorus->worldTransform * pvMatrix;
#endif

    std::shared_ptr<VertexBuffer> vbuffer = mTorus->GetVertexBuffer();
    unsigned int numVertices = vbuffer->GetNumElements();
    Vertex const* vertex = vbuffer->Get<Vertex>();

    // Compute the extremes of the normalized display coordinates.
    float const maxFloat = std::numeric_limits<float>::max();
    float xmin = maxFloat, xmax = -maxFloat;
    float ymin = maxFloat, ymax = -maxFloat;
    for (unsigned int i = 0; i < numVertices; ++i, ++vertex)
    {
        Vector4<float> input{ vertex->position[0], vertex->position[1],
            vertex->position[2], 1.0f };
#if defined(GTE_USE_MAT_VEC)
        Vector4<float> output = pvwMatrix * input;
#else
        Vector4<float> output = input * pvwMatrix;
#endif
        // Reflect the y-values because the normalized display coordinates
        // are right-handed but the overlay rectangle coordinates are
        // left-handed.
        float invW = 1.0f / output[3];
        float x = output[0] * invW;
        float y = -output[1] * invW;
        if (x < xmin)
        {
            xmin = x;
        }
        if (x > xmax)
        {
            xmax = x;
        }
        if (y < ymin)
        {
            ymin = y;
        }
        if (y > ymax)
        {
            ymax = y;
        }
    }

    // Map normalized display coordinates [-1,1]^2 to [0,1]^2.
    xmin = 0.5f * (xmin + 1.0f);
    xmax = 0.5f * (xmax + 1.0f);
    ymin = 0.5f * (ymin + 1.0f);
    ymax = 0.5f * (ymax + 1.0f);

    // Update the overlay to the region covered by the bounding rectangle.
    std::array<int, 4> rectangle;
    rectangle[0] = static_cast<int>(xmin * mXSize);
    rectangle[1] = static_cast<int>(ymin * mYSize);
    rectangle[2] = static_cast<int>((xmax - xmin) * mXSize);
    rectangle[3] = static_cast<int>((ymax - ymin) * mYSize);
    mOverlay->SetOverlayRectangle(rectangle);
    mEngine->Update(mOverlay->GetVertexBuffer());
}

#endif

