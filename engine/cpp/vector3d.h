#ifndef VECTOR3D_H
#define VECTOR3D_H

#include <vector>
#include <omp.h>
#include "common.h"

#include <assert.h>

namespace vd
{

template <typename T>
class vector3d
{
    dim3 _sizes;
    std::vector<T> _container;

public:
    vector3d(const dim3 &sizes, const T &initValue);

    const dim3 &sizes() const { return _sizes; }

    const T &operator[] (const int3 &coords) const
    {
        int3 cc = correct(coords);
        uint i = index(cc);
        return _container[i];
    }

    T &operator[] (const int3 &coords)
    {
        return _container[index(correct(coords))];
    }

    template <class Lambda>
    void each(const Lambda &lambda) const;

    template <class Lambda>
    void ip_each(const Lambda &lambda) const;

//    template <class Lambda>
//    void map(const Lambda &lambda);

//    template <class Lambda>
//    void mapIndex(const Lambda &lambda);

    template <typename R, class Lambda>
    R reduce_plus(R initValue, const Lambda &lambda) const;

private:
    uint index(const int3 &coords) const
    {
        return _sizes.x * _sizes.y * coords.z + _sizes.x * coords.y + coords.x;
    }

    int3 correct(const int3 &coords) const
    {
        assert(coords.z >= 0);
        assert(coords.z < (int)_sizes.z);

        int3 result = coords;
        result.x = correctOne(coords.x, _sizes.x);
        result.y = correctOne(coords.y, _sizes.y);
        return result;
    }

    int correctOne(int value, uint max) const
    {
        if (value < 0) return (int)max + value;
        else if (value >= (int)max) return (int)max - value;
        return value;
    }
};

template <typename T>
vector3d<T>::vector3d(const dim3 &sizes, const T &initValue) : _sizes(sizes), _container(sizes.N(), initValue)
{
}

template <typename T>
template <class Lambda>
void vector3d<T>::each(const Lambda &lambda) const
{
#pragma omp parallel for shared(lambda) schedule(dynamic) // TODO: too small var!
    for (int i = 0; i < _sizes.N(); ++i)
    {
        lambda(_container[i]);
    }
}

template <typename T>
template <class Lambda>
void vector3d<T>::ip_each(const Lambda &lambda) const
{

#pragma omp for schedule(dynamic) // TODO: too small var!
    for (int i = 0; i < _sizes.N(); ++i)
    {
        lambda(_container[i]);
    }
}

//template <typename T>
//template <class Lambda>
//void vector3d<T>::map(const Lambda &lambda)
//{
//#pragma omp parallel for shared(lambda)
//    for (int i = 0; i < _sizes.N(); ++i)
//        _container[i] = lambda(_container[i]);
//}

//template <typename T>
//template <class Lambda>
//void vector3d<T>::mapIndex(const Lambda &lambda)
//{
//    uint n = 0;
//    for (int x = 0; x < _sizes.x; ++x)
//        for (int y = 0; y < _sizes.y; ++y)
//            for (int z = 0; z < _sizes.z; ++z)
//                _container[n++] = lambda(int3(x, y, z));
//}

template <typename T>
template <typename R, class Lambda>
R vector3d<T>::reduce_plus(R initValue, const Lambda &lambda) const
{
    R sum = initValue;
#pragma omp parallel for reduction(+:sum) shared(lambda)
    for (int i = 0; i < _sizes.N(); ++i)
    {
        sum += lambda(_container[i]);
    }
    return sum;
}

}

#endif // VECTOR3D_H
