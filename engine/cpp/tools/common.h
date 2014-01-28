#ifndef COMMON_H
#define COMMON_H

#include <ostream>

// below includes is not used there, but they very useful everywhere where used it
#include <assert.h>

#ifdef PRINT
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

namespace common
{

#define DVOP(OPR) \
    template <class U> \
    auto operator OPR (const dv3<U, DEFAULT_VALUE> &other) const \
        -> dv3<decltype(this->x OPR other.x), DEFAULT_VALUE> \
    { \
        return dv3<decltype(this->x OPR other.x), DEFAULT_VALUE>( \
            x OPR other.x, y OPR other.y, z OPR other.z); \
    }


template <typename T, int DEFAULT_VALUE>
class dv3
{
    typedef dv3<T, DEFAULT_VALUE> CurrentType;

public:
    T x, y, z;
    dv3(T x = DEFAULT_VALUE, T y = DEFAULT_VALUE, T z = DEFAULT_VALUE) : x(x), y(y), z(z) {}

    DVOP(+)
    DVOP(*)

    friend std::ostream &operator << (std::ostream &os, const CurrentType &v)
    {
        os << "(" << v.x << ", " << v.y << ", " << v.z << ")";
        return os;
    }

#ifndef NDEBUG
    bool operator == (const CurrentType &another) const
    {
        return x == another.x && y == another.y && z == another.z;
    }
#endif // NDEBUG
};

}

typedef unsigned short ushort;
typedef unsigned int uint;
typedef unsigned long long ullong;

struct uint3 : public common::dv3<uint, 0>
{
    template <class... Args>
    uint3(Args... args) : dv3(args...) {}
};

struct int3 : public common::dv3<int, 0>
{
    template <class... Args>
    int3(Args... args) : dv3(args...) {}
};

struct dim3 : public common::dv3<uint, 1>
{
    template <class... Args>
    dim3(Args... args) : dv3(args...) {}

    uint N() const
    {
        return x * y * z;
    }
};

struct float3 : public common::dv3<float, 0>
{
    template <class... Args>
    float3(Args... args) : dv3(args...) {}
};

}

#endif // COMMON_H
