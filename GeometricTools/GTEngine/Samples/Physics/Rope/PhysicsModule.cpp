// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include "PhysicsModule.h"


PhysicsModule::PhysicsModule(int numParticles, float step,
    Vector3<float> const& gravity, Vector3<float> const& wind,
    float windChangeAmplitude, float viscosity)
    :
    MassSpringCurve<3, float>(numParticles, step),
    enableWind(false),
    enableWindChange(false),
    mGravity(gravity),
    mWind(wind),
    mWindChangeAmplitude(windChangeAmplitude),
    mViscosity(viscosity),
    mRnd(-1.0f, 1.0f)
{
}

Vector<3, float> PhysicsModule::ExternalAcceleration(int i, float,
    std::vector<Vector<3, float>> const&,
    std::vector<Vector<3, float>> const& velocity)
{
    // Acceleration due to gravity.
    Vector3<float> acceleration = mGravity;

    // Acceleration due to wind.
    if (enableWind)
    {
        if (enableWindChange)
        {
            // Generate random direction close to last one.
            Vector3<float> basis[3];
            basis[0] = mWind;
            float length = Normalize(basis[0]);
            ComputeOrthogonalComplement(1, basis);
            float uDelta = mWindChangeAmplitude * mRnd(mMte);
            float vDelta = mWindChangeAmplitude * mRnd(mMte);
            basis[0] += uDelta * basis[1] + vDelta * basis[2];
            Normalize(basis[0]);
            mWind = length * basis[0];
        }
        acceleration += mWind;
    }

    // Add in a friction term; otherwise the system tends to be stiff, in the
    // sense of numerical stability,  and leads to oscillatory behavior.
    acceleration -= mViscosity*velocity[i];

    return acceleration;
}

