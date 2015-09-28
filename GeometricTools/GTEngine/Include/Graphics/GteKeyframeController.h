// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#pragma once

#include <Graphics/GteTransformController.h>
#include <Mathematics/GteQuaternion.h>

namespace gte
{

class GTE_IMPEXP KeyframeController : public TransformController
{
public:
    // Construction and destruction.  If the translations, rotations, and
    // scales all share the same keyframe times, then numCommonTimes is
    // set to a positive number.  Each remaining number is numCommonTimes
    // when the channel exists or zero when it does not.  If the keyframe
    // times are not shared, then numCommonTimes must be set to zero and
    // the remaining numbers set to the appropriate values--positive when
    // the channel exists or zero otherwise.
    //
    // The Transform input initializes the controlled object's local
    // transform.  The previous behavior of this class was to fill in only
    // those transformation channels represented by the key frames, which
    // relied implicitly on the Spatial mObject to have its other channels
    // set appropriately by the application.  Now KeyframeController sets
    // *all* the channels.
    virtual ~KeyframeController();
    KeyframeController(int numCommonTimes, int numTranslations,
        int numRotations, int numScales, Transform const& localTransform);

    // Member access.  After calling the constructor, you must set the data
    // using these functions.
    inline int GetNumCommonTimes() const;
    inline float* GetCommonTimes() const;

    inline int GetNumTranslations() const;
    inline float* GetTranslationTimes() const;
    inline Vector4<float>* GetTranslations() const;

    inline int GetNumRotations() const;
    inline float* GetRotationTimes() const;
    inline Quaternion<float>* GetRotations() const;

    inline int GetNumScales() const;
    inline float* GetScaleTimes() const;
    inline float* GetScales() const;

    // The animation update.  The application time is in milliseconds.
    virtual bool Update(double applicationTime);

protected:
    // Support for looking up keyframes given the specified time.
    static void GetKeyInfo(float ctrlTime, int numTimes, float* times,
        int& lastIndex, float& normTime, int& i0, int& i1);

    Vector4<float> GetTranslate(float normTime, int i0, int i1);
    Matrix4x4<float> GetRotate(float normTime, int i0, int i1);
    float GetScale(float normTime, int i0, int i1);

    // This array is used only when times are shared by translations,
    // rotations, and scales.
    int mNumCommonTimes;
    float* mCommonTimes;

    int mNumTranslations;
    float* mTranslationTimes;
    Vector4<float>* mTranslations;

    int mNumRotations;
    float* mRotationTimes;
    Quaternion<float>* mRotations;

    int mNumScales;
    float* mScaleTimes;
    float* mScales;

    // Cached indices for the last found pair of keys used for interpolation.
    // For a sequence of times, this guarantees an O(1) lookup.
    int mTLastIndex, mRLastIndex, mSLastIndex, mCLastIndex;
};


inline int KeyframeController::GetNumCommonTimes() const
{
    return mNumCommonTimes;
}

inline float* KeyframeController::GetCommonTimes() const
{
    return mCommonTimes;
}

inline int KeyframeController::GetNumTranslations() const
{
    return mNumTranslations;
}

inline float* KeyframeController::GetTranslationTimes() const
{
    return mTranslationTimes;
}

inline Vector4<float>* KeyframeController::GetTranslations() const
{
    return mTranslations;
}

inline int KeyframeController::GetNumRotations() const
{
    return mNumRotations;
}

inline float* KeyframeController::GetRotationTimes() const
{
    return mRotationTimes;
}

inline Quaternion<float>* KeyframeController::GetRotations() const
{
    return mRotations;
}

inline int KeyframeController::GetNumScales() const
{
    return mNumScales;
}

inline float* KeyframeController::GetScaleTimes() const
{
    return mScaleTimes;
}

inline float* KeyframeController::GetScales() const
{
    return mScales;
}


}
