// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <Graphics/GteKeyframeController.h>
#include <Graphics/GteSpatial.h>
#include <Mathematics/GteRotation.h>
using namespace gte;


KeyframeController::~KeyframeController()
{
    if (mNumCommonTimes > 0)
    {
        delete[] mCommonTimes;
    }
    else
    {
        delete[] mTranslationTimes;
        delete[] mRotationTimes;
        delete[] mScaleTimes;
    }

    delete[] mTranslations;
    delete[] mRotations;
    delete[] mScales;
}

KeyframeController::KeyframeController(int numCommonTimes,
    int numTranslations, int numRotations, int numScales,
    const Transform& localTransform)
    :
    TransformController(localTransform),
    mNumCommonTimes(0),
    mCommonTimes(nullptr),
    mNumTranslations(0),
    mTranslationTimes(nullptr),
    mTranslations(nullptr),
    mNumRotations(0),
    mRotationTimes(nullptr),
    mRotations(nullptr),
    mNumScales(0),
    mScaleTimes(nullptr),
    mScales(nullptr),
    mTLastIndex(0),
    mRLastIndex(0),
    mSLastIndex(0),
    mCLastIndex(0)
{
    if (numCommonTimes > 0)
    {
        mNumCommonTimes = numCommonTimes;
        mCommonTimes = new float[mNumCommonTimes];

        if (numTranslations > 0)
        {
            mNumTranslations = numTranslations;
            mTranslationTimes = mCommonTimes;
            mTranslations = new Vector4<float>[mNumTranslations];
        }

        if (numRotations > 0)
        {
            mNumRotations = numRotations;
            mRotationTimes = mCommonTimes;
            mRotations = new Quaternion<float>[mNumRotations];
        }

        if (numScales > 0)
        {
            mNumScales = numScales;
            mScaleTimes = mCommonTimes;
            mScales = new float[mNumScales];
        }
    }
    else
    {
        if (numTranslations > 0)
        {
            mNumTranslations = numTranslations;
            mTranslationTimes = new float[mNumTranslations];
            mTranslations = new Vector4<float>[mNumTranslations];
        }

        if (numRotations > 0)
        {
            mNumRotations = numRotations;
            mRotationTimes = new float[mNumRotations];
            mRotations = new Quaternion<float>[mNumRotations];
        }

        if (numScales > 0)
        {
            mNumScales = numScales;
            mScaleTimes = new float[mNumScales];
            mScales = new float[mNumScales];
        }
    }
}

bool KeyframeController::Update(double applicationTime)
{
    if (!Controller::Update(applicationTime))
    {
        return false;
    }

    float ctrlTime = static_cast<float>(GetControlTime(applicationTime));
    float normTime = 0.0f;
    int i0 = 0, i1 = 0;
    Vector4<float> trn;
    Matrix4x4<float> rot;
    float scale;

    // The logic here checks for equal-time arrays to minimize the number of
    // times GetKeyInfo is called.
    if (mNumCommonTimes > 0)
    {
        GetKeyInfo(ctrlTime, mNumCommonTimes, mCommonTimes, mCLastIndex,
            normTime, i0, i1);

        if (mNumTranslations > 0)
        {
            trn = GetTranslate(normTime, i0, i1);
            mLocalTransform.SetTranslation(trn);
        }

        if (mNumRotations > 0)
        {
            rot = GetRotate(normTime, i0, i1);
            mLocalTransform.SetRotation(rot);
        }

        if (mNumScales > 0)
        {
            scale = GetScale(normTime, i0, i1);
            mLocalTransform.SetUniformScale(scale);
        }
    }
    else
    {
        if (mNumTranslations > 0)
        {
            GetKeyInfo(ctrlTime, mNumTranslations, mTranslationTimes,
                mTLastIndex, normTime, i0, i1);
            trn = GetTranslate(normTime, i0, i1);
            mLocalTransform.SetTranslation(trn);
        }

        if (mNumRotations > 0)
        {
            GetKeyInfo(ctrlTime, mNumRotations, mRotationTimes, mRLastIndex,
                normTime, i0, i1);
            rot = GetRotate(normTime, i0, i1);
            mLocalTransform.SetRotation(rot);
        }

        if (mNumScales > 0)
        {
            GetKeyInfo(ctrlTime, mNumScales, mScaleTimes, mSLastIndex,
                normTime, i0, i1);
            scale = GetScale(normTime, i0, i1);
            mLocalTransform.SetUniformScale(scale);
        }
    }

    Spatial* spatial = reinterpret_cast<Spatial*>(mObject);
    spatial->localTransform = mLocalTransform;
    return true;
}

void KeyframeController::GetKeyInfo(float ctrlTime, int numTimes,
    float* times, int& lastIndex, float& normTime, int& i0, int& i1)
{
    if (ctrlTime <= times[0])
    {
        normTime = 0.0f;
        lastIndex = 0;
        i0 = 0;
        i1 = 0;
        return;
    }

    if (ctrlTime >= times[numTimes - 1])
    {
        normTime = 0.0f;
        lastIndex = numTimes - 1;
        i0 = lastIndex;
        i1 = lastIndex;
        return;
    }

    int nextIndex;
    if (ctrlTime > times[lastIndex])
    {
        nextIndex = lastIndex + 1;
        while (ctrlTime >= times[nextIndex])
        {
            lastIndex = nextIndex;
            ++nextIndex;
        }

        i0 = lastIndex;
        i1 = nextIndex;
        normTime = (ctrlTime - times[i0]) / (times[i1] - times[i0]);
    }
    else if (ctrlTime < times[lastIndex])
    {
        nextIndex = lastIndex - 1;
        while (ctrlTime <= times[nextIndex])
        {
            lastIndex = nextIndex;
            --nextIndex;
        }

        i0 = nextIndex;
        i1 = lastIndex;
        normTime = (ctrlTime - times[i0]) / (times[i1] - times[i0]);
    }
    else
    {
        normTime = 0.0f;
        i0 = lastIndex;
        i1 = lastIndex;
    }
}

Vector4<float> KeyframeController::GetTranslate(float normTime, int i0,
    int i1)
{
    Vector4<float> trn = mTranslations[i0] + normTime *
        (mTranslations[i1] - mTranslations[i0]);
    return trn;
}

Matrix4x4<float> KeyframeController::GetRotate(float normTime, int i0, int i1)
{
    Quaternion<float> q = Slerp(normTime, mRotations[i0], mRotations[i1]);
    Matrix4x4<float> rot = Rotation<4, float>(q);
    return rot;
}

float KeyframeController::GetScale(float normTime, int i0, int i1)
{
    return mScales[i0] + normTime * (mScales[i1] - mScales[i0]);
}

