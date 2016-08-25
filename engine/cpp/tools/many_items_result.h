#ifndef MANY_ITEMS_RESULT_H
#define MANY_ITEMS_RESULT_H

#include "common.h"

namespace vd
{

// Almost the same as std::array
template <class T, ushort NUM>
class ManyItemsResult
{
    T *_items[NUM];

public:
    enum : ushort { QUANTITY = NUM };

    T *operator [] (uint i)
    {
        return _items[i];
    }

    bool all()
    {
        for (uint i = 0; i < NUM; ++i)
        {
            if (_items[i] == nullptr) return false;
        }
        return true;
    }

protected:
    ManyItemsResult()
    {
        for (uint i = 0; i < NUM; ++i)
        {
            _items[i] = nullptr;
        }
    }

    ManyItemsResult(T *items[NUM])
    {
        for (uint i = 0; i < NUM; ++i)
        {
            _items[i] = items[i];
        }
    }

    template <class... Args>
    ManyItemsResult(Args... args) : _items { args... } {}

    ManyItemsResult(ManyItemsResult<T, NUM> &&) = default;
    ManyItemsResult<T, NUM> &operator = (ManyItemsResult<T, NUM> &&) = default;

private:
    ManyItemsResult(const ManyItemsResult<T, NUM> &) = delete;
    ManyItemsResult<T, NUM> &operator = (const ManyItemsResult<T, NUM> &) = delete;
};

}

#endif // MANY_ITEMS_RESULT_H
