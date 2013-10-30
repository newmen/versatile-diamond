#ifndef COLLECTOR_H
#define COLLECTOR_H

#include <vector>
#include "common.h"

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

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
    template <class L> inline void ompEach(const L &lambda);
};

template <class T, ushort NUM>
template <ushort ID>
void Collector<T, NUM>::store(T *item)
{
    static_assert(ID < NUM, "Wrong ID");

#ifdef PARALLEL
#pragma omp critical
    {
#endif // PARALLEL
        _collects[ID].push_back(item);
#ifdef PARALLEL
    }
#endif // PARALLEL
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
#ifdef PARALLEL
#pragma omp for
#endif // PARALLEL
    for (int i = 0; i < NUM; ++i)
    {
        lambda(_collects[i]);
    }
}

}

#endif // COLLECTOR_H
