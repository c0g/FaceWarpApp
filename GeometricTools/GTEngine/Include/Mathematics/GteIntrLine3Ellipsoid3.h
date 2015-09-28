// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Mathematics/GteMatrix3x3.h>
#include <Mathematics/GteHyperellipsoid.h>
#include <Mathematics/GteLine.h>
#include <Mathematics/GteFIQuery.h>
#include <Mathematics/GteTIQuery.h>

// The queries consider the ellipsoid to be a solid.

namespace gte
{

template <typename Real>
class TIQuery<Real, Line3<Real>, Ellipsoid3<Real>>
{
public:
    struct Result
    {
        bool intersect;
    };

    Result operator()(Line3<Real> const& line,
        Ellipsoid3<Real> const& ellipsoid);
};

template <typename Real>
class FIQuery<Real, Line3<Real>, Ellipsoid3<Real>>
{
public:
    struct Result
    {
        bool intersect;
        int numIntersections;
        std::array<Real, 2> parameter;
        std::array<Vector3<Real>, 2> point;
    };

    Result operator()(Line3<Real> const& line,
        Ellipsoid3<Real> const& ellipsoid);

protected:
    void DoQuery(Vector3<Real> const& lineOrigin,
        Vector3<Real> const& lineDirection, Ellipsoid3<Real> const& ellipsoid,
        Result& result);
};


template <typename Real>
typename TIQuery<Real, Line3<Real>, Ellipsoid3<Real>>::Result
TIQuery<Real, Line3<Real>, Ellipsoid3<Real>>::operator()(
    Line3<Real> const& line, Ellipsoid3<Real> const& ellipsoid)
{
    // The ellipsoid is (X-K)^T*M*(X-K)-1 = 0 and the line is X = P+t*D.
    // Substitute the line equation into the ellipsoid equation to obtain
    // a quadratic equation Q(t) = a2*t^2 + 2*a1*t + a0 = 0, where
    // a2 = D^T*M*D, a1 = D^T*M*(P-K), and a0 = (P-K)^T*M*(P-K)-1.
    Result result;

    Matrix3x3<Real> M;
    ellipsoid.GetM(M);

    Vector3<Real> diff = line.origin - ellipsoid.center;
    Vector3<Real> matDir = M*line.direction;
    Vector3<Real> matDiff = M*diff;
    Real a2 = Dot(line.direction, matDir);
    Real a1 = Dot(line.direction, matDiff);
    Real a0 = Dot(diff, matDiff) - (Real)1;

    // Intersection occurs when Q(t) has real roots.
    Real discr = a1*a1 - a0*a2;
    result.intersect = (discr >= (Real)0);
    return result;
}

template <typename Real>
typename FIQuery<Real, Line3<Real>, Ellipsoid3<Real>>::Result
FIQuery<Real, Line3<Real>, Ellipsoid3<Real>>::operator()(
    Line3<Real> const& line, Ellipsoid3<Real> const& ellipsoid)
{
    Result result;
    DoQuery(line.origin, line.direction, ellipsoid, result);
    for (int i = 0; i < result.numIntersections; ++i)
    {
        result.point[i] = line.origin + result.parameter[i] * line.direction;
    }
    return result;
}

template <typename Real>
void FIQuery<Real, Line3<Real>, Ellipsoid3<Real>>::DoQuery(
    Vector3<Real> const& lineOrigin, Vector3<Real> const& lineDirection,
    Ellipsoid3<Real> const& ellipsoid, Result& result)
{
    // The ellipsoid is (X-K)^T*M*(X-K)-1 = 0 and the line is X = P+t*D.
    // Substitute the line equation into the ellipsoid equation to obtain
    // a quadratic equation Q(t) = a2*t^2 + 2*a1*t + a0 = 0, where
    // a2 = D^T*M*D, a1 = D^T*M*(P-K), and a0 = (P-K)^T*M*(P-K)-1.
    Matrix3x3<Real> M;
    ellipsoid.GetM(M);

    Vector3<Real> diff = lineOrigin - ellipsoid.center;
    Vector3<Real> matDir = M*lineDirection;
    Vector3<Real> matDiff = M*diff;
    Real a2 = Dot(lineDirection, matDir);
    Real a1 = Dot(lineDirection, matDiff);
    Real a0 = Dot(diff, matDiff) - (Real)1;

    // Intersection occurs when Q(t) has real roots.
    Real discr = a1*a1 - a0*a2;
    if (discr > (Real)0)
    {
        result.intersect = true;
        result.numIntersections = 2;
        Real root = sqrt(discr);
        Real inv = ((Real)1) / a2;
        result.parameter[0] = (-a1 - root)*inv;
        result.parameter[1] = (-a1 + root)*inv;
    }
    else if (discr < (Real)0)
    {
        result.intersect = false;
        result.numIntersections = 0;
    }
    else
    {
        result.intersect = true;
        result.numIntersections = 1;
        result.parameter[0] = -a1 / a2;
    }
}


}
