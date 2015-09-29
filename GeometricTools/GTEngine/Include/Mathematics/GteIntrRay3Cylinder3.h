// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Mathematics/GteRay.h>
#include <Mathematics/GteIntrIntervals.h>
#include <Mathematics/GteIntrLine3Cylinder3.h>

// The queries consider the cylinder to be a solid.

namespace gte
{

template <typename Real>
class FIQuery<Real, Ray3<Real>, Cylinder3<Real>>
    :
    public FIQuery<Real, Line3<Real>, Cylinder3<Real>>
{
public:
    struct Result
        :
        public FIQuery<Real, Line3<Real>, Cylinder3<Real>>::Result
    {
        // No additional information to compute.
    };

    Result operator()(Ray3<Real> const& ray, Cylinder3<Real> const& cylinder);

protected:
    void DoQuery(Vector3<Real> const& rayOrigin,
        Vector3<Real> const& rayDirection, Cylinder3<Real> const& cylinder,
        Result& result);
};


template <typename Real>
typename FIQuery<Real, Ray3<Real>, Cylinder3<Real>>::Result
FIQuery<Real, Ray3<Real>, Cylinder3<Real>>::operator()(
    Ray3<Real> const& ray, Cylinder3<Real> const& cylinder)
{
    Result result;
    DoQuery(ray.origin, ray.direction, cylinder, result);
    for (int i = 0; i < result.numIntersections; ++i)
    {
        result.point[i] = ray.origin + result.parameter[i] * ray.direction;
    }
    return result;
}

template <typename Real>
void FIQuery<Real, Ray3<Real>, Cylinder3<Real>>::DoQuery(
    Vector3<Real> const& rayOrigin, Vector3<Real> const& rayDirection,
    Cylinder3<Real> const& cylinder, Result& result)
{
    FIQuery<Real, Line3<Real>, Cylinder3<Real>>::DoQuery(rayOrigin,
        rayDirection, cylinder, result);

    if (result.intersect)
    {
        // The line containing the ray intersects the cylinder; the t-interval
        // is [t0,t1].  The ray intersects the cylinder as long as [t0,t1]
        // overlaps the ray t-interval [0,+infinity).
        std::array<Real, 2> rayInterval =
        { (Real)0, std::numeric_limits<Real>::max() };
        FIQuery<Real, std::array<Real, 2>, std::array<Real, 2>> iiQuery;
        auto iiResult = iiQuery(result.parameter, rayInterval);
        if (iiResult.intersect)
        {
            result.numIntersections = iiResult.numIntersections;
            result.parameter = iiResult.overlap;
        }
        else
        {
            result.intersect = false;
            result.numIntersections = 0;
        }
    }
}


}
