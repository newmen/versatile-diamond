#ifndef COLLECTOR_H
#define COLLECTOR_H

#include <vector>
#include "common.h"

namespace vd
{

template <class T, uint MAX_CAPACITY = 50>
class Collector
{
    std::vector<T *> _collect;

public:
    void store(T *item);
    void clear();

protected:
    template <class L>
    inline void each(const L &lambda);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class T, uint MAX_CAPACITY>
void Collector<T, MAX_CAPACITY>::store(T *item)
{
    _collect.push_back(item);
}

template <class T, uint MAX_CAPACITY>
void Collector<T, MAX_CAPACITY>::clear()
{
    uint size = _collect.size();
    if (size == 0)
    {
        return;
    }
    else if (size < MAX_CAPACITY)
    {
        _collect.clear();
    }
    else
    {
        std::vector<T *>().swap(_collect); // with clear capacity of vector
    }
}

template <class T, uint MAX_CAPACITY>
template <class L>
void Collector<T, MAX_CAPACITY>::each(const L &lambda)
{
    for (auto item : _collect)
    {
        lambda(item);
    }
}

}

#endif // COLLECTOR_H
