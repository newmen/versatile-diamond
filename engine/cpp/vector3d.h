#ifndef VECTOR3D_H
#define VECTOR3D_H

#include <vector>
#include "common.h"

namespace vd
{

template <typename T>
class vector3d
{
    dim3 _sizes;
    std::vector<T> _container;

public:
    vector3d(const dim3 &sizes);

//    T &operator[] (const uint3 &coords) const;
//    T &operator[] (const uint3 &coords);

    template <class Lambda>
    void each(const Lambda &lambda) const;

    template <class Lambda>
    void mapIndex(const Lambda &lambda);

private:
//    uint index(const uint3 &coords) const;
};

template <typename T>
vector3d<T>::vector3d(const dim3 &sizes) : _sizes(sizes), _container(sizes.N())
{
}

//template <typename T>
//T &vector3d<T>::operator [](const uint3 &coords) const
//{
//    return _container[index(coords)];
//}

template <typename T>
template <class Lambda>
void vector3d<T>::each(const Lambda &lambda) const
{
    uint n = 0;
    for (uint z = 0; z < _sizes.z; ++z)
        for (uint y = 0; y < _sizes.y; ++y)
            for (uint x = 0; x < _sizes.x; ++x)
                lambda(_container[n++]);
}

template <typename T>
template <class Lambda>
void vector3d<T>::mapIndex(const Lambda &lambda)
{
    uint n = 0;
    for (uint z = 0; z < _sizes.z; ++z)
        for (uint y = 0; y < _sizes.y; ++y)
            for (uint x = 0; x < _sizes.x; ++x)
                _container[n++] = lambda(uint3(x, y, z));
}

//template <typename T>
//uint vector3d<T>::index(const uint3 &coords) const
//{
//    return coords.x * (1 + coords.y * (1 + coords.z));
//}

}

#endif // VECTOR3D_H
