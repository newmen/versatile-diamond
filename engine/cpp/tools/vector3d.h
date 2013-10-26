#ifndef VECTOR3D_H
#define VECTOR3D_H

#include <vector>
#include "common.h"

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

#include <assert.h>

namespace vd
{

template <typename T>
class vector3d
{
    dim3 _sizes;
    T *_data;

public:
    vector3d(const dim3 &sizes, const T &initValue);
    ~vector3d();

    T *data() { return _data; }
    uint size() const { return _sizes.N(); }
    const dim3 &sizes() const { return _sizes; }

    const T &operator[] (const int3 &coords) const
    {
        int3 cc = correct(coords);
        uint i = index(cc);
        return _data[i];
    }

    T &operator[] (const int3 &coords)
    {
        return _data[index(correct(coords))];
    }

    template <class Lambda>
    void each(const Lambda &lambda) const;

//    template <class Lambda>
//    void each_in_parallel(const Lambda &lambda) const;

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
vector3d<T>::vector3d(const dim3 &sizes, const T &initValue) : _sizes(sizes)
{
    _data = new T[_sizes.N()];
#ifdef PARALLEL
#pragma omp parallel for
#endif // PARALLEL
    for (int i = 0; i < _sizes.N(); ++i) _data[i] = initValue;
}

template <typename T>
vector3d<T>::~vector3d()
{
    delete [] _data;
}

template <typename T>
template <class Lambda>
void vector3d<T>::each(const Lambda &lambda) const
{
#ifdef PARALLEL
#pragma omp parallel for shared(lambda) schedule(dynamic)
#endif // PARALLEL
    for (int i = 0; i < _sizes.N(); ++i)
    {
        lambda(_data[i]);
    }
}

//template <typename T>
//template <class Lambda>
//void vector3d<T>::each_in_parallel(const Lambda &lambda) const
//{

//#ifdef PARALLEL
//#pragma omp for schedule(dynamic)
//#endif // PARALLEL
//    for (int i = 0; i < _sizes.N(); ++i)
//    {
//        lambda(_container[i]);
//    }
//}

//template <typename T>
//template <class Lambda>
//void vector3d<T>::map(const Lambda &lambda)
//{
//#ifdef PARALLEL
//#pragma omp parallel for shared(lambda)
//#endif // PARALLEL
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
#ifdef PARALLEL
#pragma omp parallel for reduction(+:sum) shared(lambda)
#endif // PARALLEL
    for (int i = 0; i < _sizes.N(); ++i)
    {
        sum += lambda(_data[i]);
    }
    return sum;
}

}

#endif // VECTOR3D_H
