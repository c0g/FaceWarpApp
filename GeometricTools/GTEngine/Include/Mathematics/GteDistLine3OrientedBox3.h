// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Mathematics/GteDistLine3AlignedBox3.h>
#include <Mathematics/GteLine.h>
#include <Mathematics/GteOrientedBox.h>

namespace gte
{

template <typename Real>
class DCPQuery<Real, Line3<Real>, OrientedBox3<Real>>
    :
    public DCPQuery<Real, Line3<Real>, AlignedBox3<Real>>
{
public:
    struct Result
        :
        public DCPQuery<Real, Line3<Real>, AlignedBox3<Real>>::Result
    {
        // No additional information to compute.
    };

    Result operator()(Line3<Real> const& line, OrientedBox3<Real> const& box);
};


template <typename Real>
typename DCPQuery<Real, Line3<Real>, OrientedBox3<Real>>::Result
DCPQuery<Real, Line3<Real>, OrientedBox3<Real>>::operator()(
    Line3<Real> const& line, OrientedBox3<Real> const& box)
{
    // Transform the line to the coordinate system of the oriented box.
    // In this system, the box is axis-aligned with center at the origin.
    Vector3<Real> diff = line.origin - box.center;
    Vector3<Real> point, direction;
    for (int i = 0; i < 3; ++i)
    {
        point[i] = Dot(diff, box.axis[i]);
        direction[i] = Dot(direction, box.axis[i]);
    }

    Result result;
    this->DoQuery(point, direction, box.extent, result);

    // Compute the closest point on the line.
    result.closestPoint[0] =
        line.origin + result.lineParameter*line.direction;

    // Compute the closest point on the box.
    result.closestPoint[1] = box.center;
    for (int i = 0; i < 3; ++i)
    {
        result.closestPoint[1] += point[i] * box.axis[i];
    }
    return result;
}


}
