// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Mathematics/GteMatrix4x4.h>

// The basis vectors are tested for orthogonality once.  This is useful in
// debug builds to trap incorrectly specified vectors.
#define GTE_VALIDATE_COORDINATE_FRAME_ONCE

namespace gte
{

class GTE_IMPEXP ViewVolume
{
public:
    // Construction and destruction.
    virtual ~ViewVolume();
    ViewVolume(bool isPerspective);

    // Coordinate frame support.  The default coordinate frame {P;D,U,R}
    // is in right-handed world coordinates where
    //   position  P = (0, 0,  0; 1)
    //   direction D = (0, 0, -1; 0)
    //   up        U = (0, 1,  0; 0)
    //   right     R = (1, 0,  0; 0)
    // The basis {D,U,R} is required to be a right-handed orthonormal set.
    void SetPosition(Vector4<float> const& position);

    void SetAxes(
        Vector4<float> const& dVector,
        Vector4<float> const& uVector,
        Vector4<float> const& rVector);

    void SetFrame(
        Vector4<float> const& position,
        Vector4<float> const& dVector,
        Vector4<float> const& uVector,
        Vector4<float> const& rVector);

    void GetAxes(
        Vector4<float>& dVector,
        Vector4<float>& uVector,
        Vector4<float>& rVector) const;

    void GetFrame(
        Vector4<float>& position,
        Vector4<float>& dVector,
        Vector4<float>& uVector,
        Vector4<float>& rVector) const;

    inline Vector4<float> const& GetPosition() const;
    inline Vector4<float> const& GetDVector() const;
    inline Vector4<float> const& GetUVector() const;
    inline Vector4<float> const& GetRVector() const;

    // Access the view matrix of the coordinate frame.  If D = (d0,d1,d2),
    // U = (u0,u1,u2), and R = (r0,r1,r2), then the view matrix is
    //     +-                  -+
    //     | r0 r1 r2 -Dot(R,P) |
    // V = | u0 u1 u2 -Dot(U,P) |
    //     | d0 d1 d2 -Dot(D,P) |
    //     |  0  0  0         1 |
    //     +-                  -+
    // when the GTE_USE_MAT_VEC convention is used and the view matrix
    // multiplies vectors on its right, viewMat * vector4.  The transpose
    // of the displayed matrix is used for the GTE_USE_VEC_MAT convention
    // and the view matrix multiplies vectors on its left, vector4 * viewMat.
    //
    // The inverse view matrix for GTE_USE_MAT_VEC convention is
    //          +-            -+
    //          | r0 u0 d0 p0 |
    // V^{-1} = | r1 u1 d1 p1 |
    //          | r2 u2 d2 p1 |
    //          |  0  0  0  1 |
    //          +-           -+
    // A point X = (x0,x1,x2,1) can be represented by X = P + y0*R + y1*U + y2*D,
    // where y0 = Dot(R,X-P), y1 = Dot(U,X-P), and y2 = Dot(D,X-P).  Using the
    // GTE_USE_MAT_VEC convention, if Y = (y0,y1,y2,1), then Y = V*X, where V is
    // the view matrix.
    inline const Matrix4x4<float>& GetViewMatrix() const;
    inline const Matrix4x4<float>& GetInverseViewMatrix() const;

    // View frustum support.  The view frustum has parameters [rmin,rmax],
    // [umin,umax], and [dmin,dmax].  The interval [rmin,rmax] is measured in
    // the right direction R.  These are the "left" and "right" frustum values.
    // The interval [umin,umax] is measured in the up direction U.  These are
    // the "bottom" and "top" values.  The interval [dmin,dmax] is measured
    // in the view direction D.  These are the "near" and "far" values.  The
    // frustum values are stored in an array with order based on the VF_*
    // enumerates.  The default perspective view frustum has an up field-of-view
    // of 90 degrees, an aspect ratio of 1, near value 1, and far value 10000.
    // The default orthographic view frustum has (r,u,d) in [-1,1]^2 x [0,1].
    enum
    {
        VF_DMIN = 0,  // near
        VF_DMAX = 1,  // far
        VF_UMIN = 2,  // bottom
        VF_UMAX = 3,  // top
        VF_RMIN = 4,  // left
        VF_RMAX = 5,  // right
        VF_QUANTITY = 6
    };

    inline bool IsPerspective() const;

    // Set the view frustum.  The interval [rmin,rmax] is measured in the
    // right direction R.  These are the "left" and "right" frustum values.
    // The interval [umin,umax] is measured in the up direction U.  These are
    // the "bottom" and "top" values.  The interval [dmin,dmax] is measured
    // in the view direction D.  These are the "near" and "far" values.
    void SetFrustum(float dMin, float dMax, float uMin, float uMax,
        float rMin, float rMax);

    // Set all the view frustum values simultaneously.  The input array must
    // have the order:  dmin, dmax, umin, umax, rmin, rmax.
    void SetFrustum(float const* frustum);

    // Set a symmetric view frustum (umin = -umax, rmin = -rmax) using a field
    // of view in the "up" direction and an aspect ratio "width/height".  The
    // field of view in this function must be specified in degrees and be in
    // the interval (0,180).
    void SetFrustum(float upFovDegrees, float aspectRatio, float dMin,
        float dMax);

    // Get the view frustum.
    void GetFrustum(float& dMin, float& dMax, float& uMin, float& uMax,
        float& rMin, float& rMax) const;

    // Get all the view frustum values simultaneously.
    inline float const* GetFrustum() const;

    // Get the parameters for a symmetric view frustum.  The return value is
    // 'true' iff the current frustum is symmetric, in which case the output
    // parameters are valid.
    bool GetFrustum(float& upFovDegrees, float& aspectRatio, float& dMin,
        float& dMax) const;

    // Get the individual frustum values.
    inline float GetDMin() const;
    inline float GetDMax() const;
    inline float GetUMin() const;
    inline float GetUMax() const;
    inline float GetRMin() const;
    inline float GetRMax() const;

    // Access the projection matrices of the camera.  These matrices map to
    // depths in the interval [0,1].

    // The frustum values are N (near), F (far), B (bottom), T (top),
    // L (left), and R (right).  The various matrices are as follows,
    // shown for GTE_USE_MAT_VEC.  The transpose of these matrices are
    // used for GTE_USE_VEC_MAT.
    //
    // perspective
    //   +-                                               -+
    //   | 2*N/(R-L)  0           -(R+L)/(R-L)  0          |
    //   | 0          2*N/(T-B)   -(T+B)/(T-B)  0          |
    //   | 0          0           F/(F-N)       -N*F/(F-N) |
    //   | 0          0           1             0          |
    //   +-                                               -+
    //
    // orthographic
    //   +-                                       -+
    //   | 2/(R-L)  0  0              -(R+L)/(R-L) |
    //   | 0        2/(T-B)  0        -(T+B)/(T-B) |
    //   | 0        0        1/(F-N)  -N/(F-N)     |
    //   | 0        0        0        1            |
    //   +-                                       -+
    //
    // The projection matrix multiplies vectors on its right, projMat*vector4.

    // The returned matrix is perspective or orthographic depending on the
    // value of mIsPerspective.
    inline Matrix4x4<float> const& GetProjectionMatrix() const;

    // For advanced effects, you might want to set the projection matrix to
    // something other than the standard one.
    inline void SetProjectionMatrix(Matrix4x4<float> const& projMatrix);

    // The projection-view-world matrix is commonly used in the shader
    // programs to transform model-space data to clip-space data.  To avoid
    // repeatedly computing the projection-view matrix for each geometric
    // object, the product is stored and maintained in this class.
    inline Matrix4x4<float> const& GetProjectionViewMatrix() const;

protected:
    // Compute the view matrix after the frame changes and then update the
    // projection-view matrix.
    virtual void OnFrameChange();

    // Compute the projection matrices after the frustum changes and then
    // update the projection-view matrix.
    virtual void OnFrustumChange();

    // Compute the projection-view matrix.  Derived classes can include
    // pre-view and post-projection matrices in the product.
    virtual void UpdatePVMatrix();

    // The coordinate frame.
    Vector4<float> mPosition, mDVector, mUVector, mRVector;

    // The view matrix (V) for the coordinate frame.  The storage order depends
    // on whether you define GTE_USE_MAT_VEC or GTE_USE_VEC_MAT.  The other
    // matrix is the inverse view matrix (V^{-1}).
    Matrix4x4<float> mViewMatrix;
    Matrix4x4<float> mInverseViewMatrix;

    // The projection matrixs for the view volume.
    Matrix4x4<float> mProjectionMatrix;

    // The product of the projection and view matrices.
    Matrix4x4<float> mProjectionViewMatrix;

    // The view frustum, stored in order as dmin (near), dmax (far),
    // umin (bottom), umax (top), rmin (left), and rmax (right).
    float mFrustum[VF_QUANTITY];

    // This member is 'true' for a perspective camera or 'false' for an
    // orthographic camera.
    bool mIsPerspective;

    // The use of this is controlled by conditional compilation (via
    // GTE_VALIDATE_COORDINATE_FRAME_ONCE).  It allows you to trap incorrectly
    // built frames or frames that are askew due to numerical round-off errors.
    bool mValidateCoordinateFrame;
};


inline Vector4<float> const& ViewVolume::GetPosition() const
{
    return mPosition;
}

inline Vector4<float> const& ViewVolume::GetDVector() const
{
    return mDVector;
}

inline Vector4<float> const& ViewVolume::GetUVector() const
{
    return mUVector;
}

inline Vector4<float> const& ViewVolume::GetRVector() const
{
    return mRVector;
}

inline Matrix4x4<float> const& ViewVolume::GetViewMatrix() const
{
    return mViewMatrix;
}

inline Matrix4x4<float> const& ViewVolume::GetInverseViewMatrix() const
{
    return mInverseViewMatrix;
}

inline bool ViewVolume::IsPerspective() const
{
    return mIsPerspective;
}

inline float const* ViewVolume::GetFrustum() const
{
    return mFrustum;
}

inline float ViewVolume::GetDMin() const
{
    return mFrustum[VF_DMIN];
}

inline float ViewVolume::GetDMax() const
{
    return mFrustum[VF_DMAX];
}

inline float ViewVolume::GetUMin() const
{
    return mFrustum[VF_UMIN];
}

inline float ViewVolume::GetUMax() const
{
    return mFrustum[VF_UMAX];
}

inline float ViewVolume::GetRMin() const
{
    return mFrustum[VF_RMIN];
}

inline float ViewVolume::GetRMax() const
{
    return mFrustum[VF_RMAX];
}

inline Matrix4x4<float> const& ViewVolume::GetProjectionMatrix() const
{
    return mProjectionMatrix;
}

inline void ViewVolume::SetProjectionMatrix(Matrix4x4<float> const& projMatrix)
{
    mProjectionMatrix = projMatrix;
    UpdatePVMatrix();
}

inline Matrix4x4<float> const& ViewVolume::GetProjectionViewMatrix() const
{
    return mProjectionViewMatrix;
}

}
