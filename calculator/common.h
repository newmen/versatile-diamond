#ifndef COMMON_H
#define COMMON_H

namespace vd
{

namespace common
{

template <typename T, int DEFAULT_VALUE>
struct dv3
{
    T x, y, z;
    dv3(T x = DEFAULT_VALUE, T y = DEFAULT_VALUE, T z = DEFAULT_VALUE) : x(x), y(y), z(z) {}
};

}

typedef unsigned int uint;

struct uint3 : public common::dv3<uint, 0>
{
    using dv3::dv3;
};

struct dim3 : public common::dv3<uint, 1>
{
    using dv3::dv3;

    uint N() const
    {
        return x * y * z;
    }
};

}

#endif // COMMON_H
