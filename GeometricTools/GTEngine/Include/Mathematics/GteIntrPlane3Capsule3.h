// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Mathematics/GteDistPoint3Plane3.h>
#include <Mathematics/GteCapsule.h>
#include <Mathematics/GteTIQuery.h>

namespace gte
{

template <typename Real>
class TIQuery<Real, Plane3<Real>, Capsule3<Real>>
{
public:
    struct Result
    {
        bool intersect;
    };

    Result operator()(Plane3<Real> const& plane,
        Capsule3<Real> const& capsule);
};


template <typename Real>
typename TIQuery<Real, Plane3<Real>, Capsule3<Real>>::Result
TIQuery<Real, Plane3<Real>, Capsule3<Real>>::operator()(
    Plane3<Real> const& plane, Capsule3<Real> const& capsule)
{
    Result result;

    DCPQuery<Real, Vector3<Real>, Plane3<Real>> vpQuery;
    Real sdistance0 = vpQuery(capsule.segment.p[0], plane).signedDistance;
    Real sdistance1 = vpQuery(capsule.segment.p[1], plane).signedDistance;
    if (sdistance0 * sdistance1 <= (Real)0)
    {
        // A capsule segment endpoint is on the plane or the two endpoints
        // are on opposite sides of the plane.
        result.intersect = true;
        return result;
    }

    // The endpoints on same side of plane, but the endpoint spheres might
    // intersect the plane.
    result.intersect =
        std::abs(sdistance0) <= capsule.radius ||
        std::abs(sdistance1) <= capsule.radius;
    return result;
}


}
