#ifndef MANY_ITEMS_RESULT_H
#define MANY_ITEMS_RESULT_H

#include "common.h"

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
        bool result = true;
        for (int i = 0; i < NUM; ++i)
        {
            result = result && (_items[i] != nullptr);
        }
        return result;
    }

protected:
    ManyItemsResult()
    {
        for (int i = 0; i < NUM; ++i)
        {
            _items[i] = nullptr;
        }
    }

    ManyItemsResult(T *items[NUM])
    {
        for (int i = 0; i < NUM; ++i)
        {
            _items[i] = items[i];
        }
    }

    ManyItemsResult(ManyItemsResult<T, NUM> &&) = default;
    ManyItemsResult<T, NUM>& operator = (ManyItemsResult<T, NUM> &&) = default;

#ifdef NEYRON
    T *item(uint index) { return _items[index]; }
#endif // NEYRON

private:
    ManyItemsResult(const ManyItemsResult<T, NUM> &) = delete;
    ManyItemsResult<T, NUM>& operator = (const ManyItemsResult<T, NUM> &) = delete;
};

#endif // MANY_ITEMS_RESULT_H
