// Geometric Tools LLC, Redmond WA 98052
// Copyright (c) 1998-2015
// Distributed under the Boost Software License, Version 1.0.
// http://www.boost.org/LICENSE_1_0.txt
// http://www.geometrictools.com/License/Boost/LICENSE_1_0.txt
// File Version: 2.0.0 (2015/09/23)

#include <GTEnginePCH.h>
#include <Mathematics/GteBitHacks.h>
#include <Mathematics/GteUIntegerAP32.h>
#include <algorithm>
using namespace gte;

#if defined(GTE_COLLECT_UINTEGERAP32_STATISTICS)
std::atomic<size_t> UIntegerAP32::msMaxSize;
#endif


UIntegerAP32::UIntegerAP32()
    :
    mNumBits(0)
{
}

UIntegerAP32::UIntegerAP32(UIntegerAP32 const& number)
{
    *this = number;
}

UIntegerAP32::UIntegerAP32(uint32_t number)
{
    if (number > 0)
    {
        int32_t first = GetLeadingBit(number);
        int32_t last = GetTrailingBit(number);
        mNumBits = first - last + 1;
        mBits.resize(1);
        mBits[0] = (number >> last);
    }
    else
    {
        mNumBits = 0;
    }

#if defined(GTE_COLLECT_UINTEGERAP32_STATISTICS)
    AtomicMax(msMaxSize, mBits.size());
#endif
}

UIntegerAP32::UIntegerAP32(uint64_t number)
{
    if (number > 0)
    {
        int32_t first = GetLeadingBit(number);
        int32_t last = GetTrailingBit(number);
        number >>= last;
        mNumBits = first - last + 1;
        mBits.resize(1 + (mNumBits - 1) / 32);
        mBits[0] = GTE_GET_LO_U64(number);
        if (mBits.size() > 1)
        {
            mBits[1] = GTE_GET_HI_U64(number);
        }
    }
    else
    {
        mNumBits = 0;
    }

#if defined(GTE_COLLECT_UINTEGERAP32_STATISTICS)
    AtomicMax(msMaxSize, mBits.size());
#endif
}

UIntegerAP32::UIntegerAP32(int numBits)
    :
    mNumBits(numBits),
    mBits(1 + (numBits - 1) / 32)
{
#if defined(GTE_COLLECT_UINTEGERAP32_STATISTICS)
    AtomicMax(msMaxSize, mBits.size());
#endif
}

UIntegerAP32& UIntegerAP32::operator=(UIntegerAP32 const& number)
{
    mNumBits = number.mNumBits;
    mBits = number.mBits;
    return *this;
}

UIntegerAP32::UIntegerAP32(UIntegerAP32&& number)
{
    *this = std::move(number);
}

UIntegerAP32& UIntegerAP32::operator=(UIntegerAP32&& number)
{
    mNumBits = number.mNumBits;
    mBits = std::move(number.mBits);
    number.mNumBits = 0;
    return *this;
}

void UIntegerAP32::SetNumBits(uint32_t numBits)
{
    mNumBits = numBits;
    if (mNumBits > 0)
    {
        mBits.resize(1 + (numBits - 1) / 32);
    }
    else
    {
        mBits.clear();
    }

#if defined(GTE_COLLECT_UINTEGERAP32_STATISTICS)
    AtomicMax(msMaxSize, mBits.size());
#endif
}

bool UIntegerAP32::Write(std::ofstream& output) const
{
    if (output.write((char const*)&mNumBits, sizeof(mNumBits)).bad())
    {
        return false;
    }

    std::size_t size = mBits.size();
    if (output.write((char const*)&size, sizeof(size)).bad())
    {
        return false;
    }

    return output.write((char const*)&mBits[0], size*sizeof(mBits[0])).good();
}

bool UIntegerAP32::Read(std::ifstream& input)
{
    if (input.read((char*)&mNumBits, sizeof(mNumBits)).bad())
    {
        return false;
    }

    std::size_t size;
    if (input.read((char*)&size, sizeof(size)).bad())
    {
        return false;
    }

    mBits.resize(size);
    return input.read((char*)&mBits[0], size*sizeof(mBits[0])).good();
}

