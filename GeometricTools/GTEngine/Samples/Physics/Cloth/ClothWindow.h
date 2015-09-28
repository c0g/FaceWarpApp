// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <GTEngine.h>
#include <chrono>
#include "PhysicsModule.h"
using namespace gte;

class ClothWindow : public Window3
{
public:
    ClothWindow(Parameters& parameters);

    virtual void OnIdle();
    virtual bool OnCharPress(unsigned char key, int x, int y);

private:
    bool SetEnvironment();
    void InitializeCamera();
    void CreateSprings();
    void CreateCloth();
    void PhysicsTick();
    void GraphicsTick();

    struct Vertex
    {
        Vector3<float> position;
        Vector2<float> tcoord;
    };

    std::shared_ptr<RasterizerState> mWireState;
    std::shared_ptr<Visual> mCloth;

    // The masses are located at the control points of a spline curve.  The
    // control points are connected by a mass-spring system.
    std::unique_ptr<PhysicsModule> mModule;
    std::shared_ptr<BSplineSurface<3, float>> mSpline;
    std::unique_ptr<RectangleSurface<float>> mSurface;

    std::chrono::high_resolution_clock::time_point mTime0, mTime1;
};
