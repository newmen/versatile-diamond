#ifndef MC_H
#define MC_H

#include <cstdlib>
#include <chrono>
#include <random>
#include <omp.h>
#include "events_container.h"
#include "multi_events_container.h"

// for #compareContainers()
#define MULTI_EVENTS_INDEX_SHIFT 1000

namespace vd
{

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
class MC
{
    typedef std::chrono::high_resolution_clock McClock;
    std::mt19937 _randomGenerator;

    double _totalRate = 0;

    EventsContainer _events[EVENTS_NUM];
    MultiEventsContainer _multiEvents[MULTI_EVENTS_NUM];
    uint _order[EVENTS_NUM + MULTI_EVENTS_NUM];

public:
    MC();

    void sort();

    void doRandom();
    double totalRate() const { return _totalRate; }

    template <ushort RT> void add(Reaction *reaction);
    template <ushort RT> void remove(Reaction *reaction);

    template <ushort RT> void addMul(Reaction *reaction, uint n);
    template <ushort RT> void removeMul(Reaction *reaction, uint n);

private:
    void updateRate(double r)
    {
//#pragma omp atomic
        _totalRate += r;
    }

    int compareContainers(const void *a, const void *b);
    BaseEventsContainer *events(uint orderIndex) const;
};

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
MC<EVENTS_NUM, MULTI_EVENTS_NUM>::MC()
{
    static_assert(EVENTS_NUM < MULTI_EVENTS_INDEX_SHIFT, "MULTI_EVENTS_INDEX_SHIFT too small, need to increase it value");

    McClock::duration d = McClock::now().time_since_epoch();
    _randomGenerator.seed(d.count());

    for (int i = 0; i < EVENTS_NUM; ++i) _order[i] = i;
    for (int i = 0; i < MULTI_EVENTS_NUM; ++i) _order[i] = i + MULTI_EVENTS_INDEX_SHIFT;

}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doRandom()
{
    std::uniform_real_distribution<double> distribution(0.0, totalRate());
    double r = distribution(_randomGenerator);


}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::sort()
{
    qsort(_order, EVENTS_NUM, sizeof(uint), compareContainers);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
int MC<EVENTS_NUM, MULTI_EVENTS_NUM>::compareContainers(const void *a, const void *b)
{
    const BaseEventsContainer &ae = events(*(uint *)a);
    const BaseEventsContainer &be = events(*(uint *)b);

    if (ae.commonRate() < be.commonRate()) return -1;
    else if (ae.commonRate() > be.commonRate()) return 1;
    else return 0;
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
BaseEventsContainer *MC<EVENTS_NUM, MULTI_EVENTS_NUM>::events(uint orderIndex) const
{
    if (orderIndex < MULTI_EVENTS_INDEX_SHIFT) return _events[orderIndex];
    else _multiEvents[orderIndex - MULTI_EVENTS_INDEX_SHIFT];
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(Reaction *reaction)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction type");

#pragma omp critical
    {
        _events[RT].add(reaction);
        updateRate(reaction->rate());
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(Reaction *reaction)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction type");

#pragma omp critical
    {
        updateRate(-reaction->rate());
        _events[RT].remove(reaction);
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::addMul(Reaction *reaction, uint n)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction type");

#pragma omp critical
    {
        _multiEvents[RT].add(reaction, n);
        updateRate(reaction->rate() * n);
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::removeMul(Reaction *reaction, uint n)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction type");

#pragma omp critical
    {
        _multiEvents[RT].remove(reaction, n);
        updateRate(-reaction->rate() * n);
    }
}

}

#endif // MC_H
