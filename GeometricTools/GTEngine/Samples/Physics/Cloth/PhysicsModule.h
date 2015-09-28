// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Physics/GteMassSpringSurface.h>
#include <Mathematics/GteVector3.h>
using namespace gte;

class PhysicsModule : public MassSpringSurface<3, float>
{
public:
    // Construction.  Gravity is controlled by the input 'gravity'.
    // Mass-spring systems tend to exhibit stiffness in the sense of numerical
    // stability.  To remedy this problem, a small amount of viscous friction
    // is added to the external force, -viscosity*velocity, where 'viscosity'
    // is a small positive constant.  The initial wind force is specified by
    // the caller.  The wind remains in effect throughout the simulation.  To
    // simulate oscillatory behavior locally, random forces are applied at
    // each mass in the direction perpendicular to the plane of the wind and
    // gravity vectors.  The amplitudes are sinusoidal.  The phases are
    // randomly generated.
    PhysicsModule(int numRows, int numCols, float step,
        Vector3<float> const& gravity, Vector3<float> const& wind,
        float viscosity, float amplitude);

    // External acceleration is due to forces of gravitation, wind, and
    // viscous friction.  The wind forces are randomly generated.
    virtual Vector<3, float> ExternalAcceleration(int i, float time,
        std::vector<Vector<3, float>> const& position,
        std::vector<Vector<3, float>> const& velocity);

protected:
    Vector3<float> mGravity, mWind, mDirection;
    float mViscosity, mAmplitude;
    std::vector<float> mPhases;
};
