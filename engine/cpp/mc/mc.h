#ifndef MC_H
#define MC_H

//#include <cstdlib>
#include <chrono>
#include <random>
#include <omp.h>
#include "events_container.h"
#include "multi_events_container.h"

#ifdef PRINT
#include <iostream>
#endif // PRINT

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

    template <ushort RT> void add(SingleReaction *reaction);
    template <ushort RT> void remove(SingleReaction *reaction);
    template <ushort RT> void doOneOfOne(); // for tests

    template <ushort RT> void addMul(MultiReaction *reaction, uint n);
    template <ushort RT> void removeMul(MultiReaction *reaction, uint n);
    template <ushort RT> void doOneOfMul(); // for tests

private:
    void recountTotalRate();
    void updateRate(double r)
    {
#pragma omp atomic
        _totalRate += r;
    }

    int compareContainers(const void *a, const void *b);
    BaseEventsContainer *events(uint orderIndex);
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

    double passRate = 0;
    for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
    {
        BaseEventsContainer *currentEvents = events(_order[i]);
        double cr = currentEvents->commonRate();
        if (r < cr + passRate)
        {
#ifdef PRINT
            std::cout << "Event " << i << " => ";
#endif // PRINT
            currentEvents->doEvent(r - passRate);
            return;
        }
        else
        {
            passRate += cr;
        }
    }

    // if event was not found
    recountTotalRate();
    BaseEventsContainer *currentEvents = events(_order[EVENTS_NUM + MULTI_EVENTS_NUM - 1]);
    currentEvents->doEvent(totalRate());
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::recountTotalRate()
{
    _totalRate = 0;
    for (uint i = 0; i < EVENTS_NUM; ++i)
    {
        _totalRate += _events[i].commonRate();
    }
    for (uint i = 0; i < MULTI_EVENTS_NUM; ++i)
    {
        _totalRate += _multiEvents[i].commonRate();
    }
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
BaseEventsContainer *MC<EVENTS_NUM, MULTI_EVENTS_NUM>::events(uint orderIndex)
{
    if (orderIndex < MULTI_EVENTS_INDEX_SHIFT) return &_events[orderIndex];
    else return &_multiEvents[orderIndex - MULTI_EVENTS_INDEX_SHIFT];
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(SingleReaction *reaction)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

#pragma omp critical
    {
#ifdef PRINT
        std::cout << "Add ";
        reaction->info();
#endif // PRINT
        _events[RT].add(reaction);
    }

    updateRate(reaction->rate());
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(SingleReaction *reaction)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

    updateRate(-reaction->rate());

//#pragma omp critical
//    {
#ifdef PRINT
        std::cout << "Remove ";
        reaction->info();
#endif // PRINT
        _events[RT].remove(reaction);
//    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::addMul(MultiReaction *reaction, uint n)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

#pragma omp critical
    {
#ifdef PRINT
        std::cout << "Add multi ";
        reaction->info();
#endif // PRINT
        _multiEvents[RT].add(reaction, n);
    }

    updateRate(reaction->rate() * n);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::removeMul(MultiReaction *reaction, uint n)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

    updateRate(-reaction->rate() * n);

#pragma omp critical
    {
#ifdef PRINT
        std::cout << "Remove multi ";
        reaction->info();
#endif // PRINT
        _multiEvents[RT].remove(reaction, n);
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfOne()
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");
    _events[RT].doEvent(0);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfMul()
{
    static_assert(RT < MULTI_EVENTS_NUM, "Wrong reaction ID");
    _multiEvents[RT].doEvent(0);
}

}

#endif // MC_H
