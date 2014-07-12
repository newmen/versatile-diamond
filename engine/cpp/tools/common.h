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

#define DVOP(OPR, OPEQ) \
    template <class U> \
    auto operator OPR (const dv3<U, DEFAULT_VALUE> &other) const \
        -> dv3<decltype(this->x OPR other.x), DEFAULT_VALUE> \
    { \
        return dv3<decltype(this->x OPR other.x), DEFAULT_VALUE>( \
            x OPR other.x, y OPR other.y, z OPR other.z); \
    } \
    \
    template <class U> \
    auto operator OPR (U value) const \
        -> dv3<decltype(this->x OPR value), DEFAULT_VALUE> \
    { \
        return dv3<decltype(this->x OPR value), DEFAULT_VALUE>( \
            x OPR value, y OPR value, z OPR value); \
    } \
    \
    dv3<T, DEFAULT_VALUE> &operator OPEQ (const dv3<T, DEFAULT_VALUE> &other) \
    { \
        x OPEQ other.x; \
        y OPEQ other.y; \
        z OPEQ other.z; \
        return *this; \
    } \
    \
    dv3<T, DEFAULT_VALUE> &operator OPEQ (T value) \
    { \
        x OPEQ value; \
        y OPEQ value; \
        z OPEQ value; \
        return *this; \
    }

template <typename T, int DEFAULT_VALUE>
class dv3
{
    typedef dv3<T, DEFAULT_VALUE> CurrentType;

public:
    T x, y, z;

    dv3(T x = DEFAULT_VALUE, T y = DEFAULT_VALUE, T z = DEFAULT_VALUE) : x(x), y(y), z(z) {}
    dv3(const CurrentType &) = default;
    dv3(CurrentType &&) = default;

    CurrentType &operator = (const CurrentType &) = default;
    CurrentType &operator = (CurrentType &&) = default;

    DVOP(+, +=)
    DVOP(-, -=)
    DVOP(*, *=)
    DVOP(/, /=)

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
    template <class... Args> uint3(Args... args) : dv3(args...) {}
};

struct int3 : public common::dv3<int, 0>
{
    template <class... Args> int3(Args... args) : dv3(args...) {}

    bool isUnit() const
    {
        return std::abs(x) <= 1 && std::abs(y) <= 1 && std::abs(z) <= 1;
    }
};

struct dim3 : public common::dv3<uint, 1>
{
    template <class... Args> dim3(Args... args) : dv3(args...) {}

    uint N() const
    {
        return x * y * z;
    }
};

struct float3 : public common::dv3<float, 0>
{
    template <class... Args> float3(Args... args) : dv3(args...) {}
};

}

#endif // COMMON_H
