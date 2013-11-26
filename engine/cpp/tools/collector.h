#ifndef COLLECTOR_H
#define COLLECTOR_H

#include <vector>
#include "common.h"

namespace vd
{

template <class T, ushort NUM>
class Collector
{
    std::vector<T *> _collects[NUM];

public:
    template <ushort ID> void store(T *item);

    void clear();

protected:
    template <class L> inline void each(const L &lambda);
};

template <class T, ushort NUM>
template <ushort ID>
void Collector<T, NUM>::store(T *item)
{
    static_assert(ID < NUM, "Wrong ID");
    _collects[ID].push_back(item);
}

template <class T, ushort NUM>
void Collector<T, NUM>::clear()
{
    for (int i = 0; i < NUM; ++i)
    {
        if (_collects[i].size() < 5)
        {
            _collects[i].clear();
        }
        else
        {
            std::vector<T *>().swap(_collects[i]); // with clear capacity of vector
        }
    }
}

template <class T, ushort NUM>
template <class L>
void Collector<T, NUM>::each(const L &lambda)
{
    for (int i = 0; i < NUM; ++i)
    {
        lambda(_collects[i]);
    }
}

}

#endif // COLLECTOR_H
