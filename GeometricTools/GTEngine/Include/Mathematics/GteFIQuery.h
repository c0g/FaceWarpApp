// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <GTEngineDEF.h>

namespace gte
{

// Find-intersection queries.

template <typename Real, typename Type0, typename Type1>
class FIQuery
{
public:
    struct Result
    {
        // A FIQuery-base class B must define a B::Result struct with member
        // 'bool intersect'.  A FIQuery-derived class D must also derive a
        // D::Result from B:Result but may have no members.  The member
        // 'intersect' is 'true' iff the primitives intersect.  The operator()
        // is non-const to allow FIQuery to store and modify private state
        // that supports the query.
    };
    Result operator()(Type0 const& primitive0, Type1 const& primitive1);
};

}
