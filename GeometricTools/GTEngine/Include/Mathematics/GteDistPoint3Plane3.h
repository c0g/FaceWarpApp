// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Mathematics/GteVector3.h>
#include <Mathematics/GteDCPQuery.h>
#include <Mathematics/GteHyperplane.h>

namespace gte
{

template <typename Real>
class DCPQuery<Real, Vector3<Real>, Plane3<Real>>
{
public:
    struct Result
    {
        Real distance, signedDistance;
        Vector3<Real> planeClosestPoint;
    };

    Result operator()(Vector3<Real> const& point, Plane3<Real> const& plane);
};


template <typename Real>
typename DCPQuery<Real, Vector3<Real>, Plane3<Real>>::Result
DCPQuery<Real, Vector3<Real>, Plane3<Real>>::operator()(
    Vector3<Real> const& point, Plane3<Real> const& plane)
{
    Result result;
    result.signedDistance = Dot(plane.normal, point) - plane.constant;
    result.distance = std::abs(result.signedDistance);
    result.planeClosestPoint = point - result.signedDistance*plane.normal;
    return result;
}


}
