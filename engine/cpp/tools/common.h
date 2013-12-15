#ifndef COMMON_H
#define COMMON_H

#include <ostream>

// below includes is not used there, but they very useful everywhere where used it
#include "caster.h"

#ifdef PRINT
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

namespace common
{

template <typename T, int DEFAULT_VALUE>
struct dv3
{
    T x, y, z;
    dv3(T x = DEFAULT_VALUE, T y = DEFAULT_VALUE, T z = DEFAULT_VALUE) : x(x), y(y), z(z) {}

#ifdef DEBUG
    bool operator == (const dv3<T, DEFAULT_VALUE> &another) const
    {
        return x == another.x && y == another.y && z == another.z;
    }
#endif // DEBUG
};

}

typedef unsigned short ushort;
typedef unsigned int uint;
typedef unsigned long long ullong;

struct uint3 : public common::dv3<uint, 0>
{
    uint3(uint x, uint y, uint z) : dv3(x, y, z) {}
//    using dv3::dv3;
};

struct int3 : public common::dv3<int, 0>
{
//    using dv3::dv3;
    int3(int x, int y, int z) : dv3(x, y, z) {}
};

struct dim3 : public common::dv3<uint, 1>
{
//    using dv3::dv3;
    dim3(uint x, uint y, uint z) : dv3(x, y, z) {}

    uint N() const
    {
        return x * y * z;
    }
};

std::ostream &operator << (std::ostream &os, const int3 &v);

}

#endif // COMMON_H
