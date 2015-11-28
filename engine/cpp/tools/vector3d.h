#ifndef VECTOR3D_H
#define VECTOR3D_H

#include "common.h"

namespace vd
{

template <typename T>
class vector3d
{
    dim3 _sizes;
    T *_data = nullptr;

public:
    vector3d(const dim3 &sizes, const T &initValue);
    ~vector3d();

    T *data() const { return _data; }

    uint size() const { return _sizes.N(); }
    const dim3 &sizes() const { return _sizes; }

    T &operator [] (const int3 &coords)
    {
        return _data[index(coords)];
    }

    template <class Lambda>
    void each(const Lambda &lambda) const;

private:
    vector3d(const vector3d<T> &) = delete;
    vector3d(vector3d<T> &&) = delete;
    vector3d<T> &operator = (const vector3d<T> &) = delete;
    vector3d<T> &operator = (vector3d<T> &&) = delete;

    uint index(const int3 &coords) const
    {
        return _sizes.x * _sizes.y * coords.z + _sizes.x * coords.y + coords.x;
    }
};

//////////////////////////////////////////////////////////////////////////////////////

template <typename T>
vector3d<T>::vector3d(const dim3 &sizes, const T &initValue) : _sizes(sizes)
{
    _data = new T[_sizes.N()];
    for (uint i = 0; i < _sizes.N(); ++i) _data[i] = initValue;
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
    for (uint i = 0; i < _sizes.N(); ++i)
    {
        lambda(_data[i]);
    }
}

}

#endif // VECTOR3D_H
