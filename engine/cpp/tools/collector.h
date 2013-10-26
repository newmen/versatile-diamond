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
    template <ushort ITN> void store(T *item);

    void clear();

protected:
    template <class L> void each(const L &lambda);
    template <class L> void ompEach(const L &lambda);
};

template <class T, ushort NUM>
template <ushort ITN>
void Collector<T, NUM>::store(T *item)
{
    static_assert(ITN < NUM, "Wrong ID");

#pragma omp critical
    {
        _collects[ITN].push_back(item);
    }
}

template <class T, ushort NUM>
void Collector<T, NUM>::clear()
{
    for (int i = 0; i < NUM; ++i)
    {
        std::vector<T *>().swap(_collects[i]); // with clear capacity of vector
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

template <class T, ushort NUM>
template <class L>
void Collector<T, NUM>::ompEach(const L &lambda)
{
#pragma omp for
    for (int i = 0; i < NUM; ++i)
    {
        lambda(_collects[i]);
    }
}

}

#endif // COLLECTOR_H
