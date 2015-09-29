// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Mathematics/GteHalfspace.h>
#include <Mathematics/GteOrientedBox.h>
#include <Mathematics/GteFIQuery.h>
#include <Mathematics/GteTIQuery.h>

// Queries for intersection of objects with halfspaces.  These are useful for
// containment testing, object culling, and clipping.

namespace gte
{

template <typename Real>
class TIQuery<Real, Halfspace3<Real>, OrientedBox3<Real>>
{
public:
    struct Result
    {
        bool intersect;
    };

    Result operator()(Halfspace3<Real> const& halfspace,
        OrientedBox3<Real> const& box);
};


template <typename Real>
typename TIQuery<Real, Halfspace3<Real>, OrientedBox3<Real>>::Result
TIQuery<Real, Halfspace3<Real>, OrientedBox3<Real>>::operator()(
    Halfspace3<Real> const& halfspace, OrientedBox3<Real> const& box)
{
    Result result;

    // Project the box center onto the normal line.  The plane of the
    // halfspace occurs at the origin (zero) of the normal line.
    Real center = Dot(halfspace.normal, box.center) - halfspace.constant;

    // Compute the radius of the interval of projection.
    Real radius =
        std::abs(box.extent[0] * Dot(halfspace.normal, box.axis[0])) +
        std::abs(box.extent[1] * Dot(halfspace.normal, box.axis[1])) +
        std::abs(box.extent[2] * Dot(halfspace.normal, box.axis[2]));

    // The box and halfspace intersect when the projection interval maximum
    // is nonnegative.
    result.intersect = (center + radius >= (Real)0);
    return result;
}


}
