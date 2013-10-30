#ifndef MC_H
#define MC_H

//#include <parallel/algorithm> // __gnu_parallel::sort
#include <algorithm> // std::sort
#include <chrono>
#include <random>
#include <vector>
#include "events_container.h"
#include "multi_events_container.h"

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

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
    std::vector<uint> _order;

public:
    MC();

    void sort();

    void doRandom();
    double totalRate() const { return _totalRate; }

    template <ushort RT> void add(SpecReaction *reaction);
    template <ushort RT> void remove(SpecReaction *reaction, bool clearMemory = true);
    template <ushort RT> void doOneOfOne(); // for tests

    template <ushort RT> void addMul(UbiquitousReaction *reaction, uint n);
    template <ushort RT> void removeMul(UbiquitousReaction *reaction, uint n);
    template <ushort RT> void doOneOfMul(); // for tests

private:
    void recountTotalRate();
    void updateRate(double r)
    {
#ifdef PARALLEL
#pragma omp atomic
#endif // PARALLEL
        _totalRate += r;
    }

    BaseEventsContainer *events(uint orderIndex);
};

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
MC<EVENTS_NUM, MULTI_EVENTS_NUM>::MC() : _order(EVENTS_NUM + MULTI_EVENTS_NUM)
{
    static_assert(EVENTS_NUM < MULTI_EVENTS_INDEX_SHIFT, "MULTI_EVENTS_INDEX_SHIFT too small, need to increase it value");

    McClock::duration d = McClock::now().time_since_epoch();
    _randomGenerator.seed(d.count());

    int i = 0;
    for (; i < EVENTS_NUM; ++i) _order[i] = i;
    for (int j = 0; j < MULTI_EVENTS_NUM; ++j) _order[i + j] = j + MULTI_EVENTS_INDEX_SHIFT;

#ifdef PRINT
    std::cout << "Inited order: " << std::endl;
    for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
    {
        std::cout << i << "-" << _order[i] << std::endl;
    }
#endif // PRINT
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doRandom()
{
#ifdef PRINT
    std::cout << "Current sizes: " << std::endl;
    for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
    {
        std::cout << i << "-" << _order[i] << ".. " << events(i)->size() << " -> " << events(i)->commonRate() << std::endl;
    }
#endif // PRINT

    std::uniform_real_distribution<double> distribution(0.0, totalRate());
    double r = distribution(_randomGenerator);
#ifdef PRINT
    std::cout << "Random number: " << r << "\n" << std::endl;
#endif // PRINT

    double passRate = 0;
    for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
    {
        BaseEventsContainer *currentEvents = events(i);
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
    sort();

#ifdef PRINT
    std::cout << "Event not found! Resort and using " << _order[EVENTS_NUM + MULTI_EVENTS_NUM - 1] << std::endl;
#endif // PRINT

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
    auto compare = [this](uint a, uint b) {
        BaseEventsContainer *ae = events(a);
        BaseEventsContainer *be = events(b);

//        std::cout << this << "] " << a << ":" << ae->commonRate() << " <=> " << b << ":" << be->commonRate() << std::endl;

        return ae->commonRate() > be->commonRate();
    };

    std::sort(_order.begin(), _order.end(), compare);
//    __gnu_parallel::sort(_order.begin(), _order.end(), compare);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
BaseEventsContainer *MC<EVENTS_NUM, MULTI_EVENTS_NUM>::events(uint index)
{
    uint orderIndex = _order[index];
    if (orderIndex < MULTI_EVENTS_INDEX_SHIFT) return &_events[orderIndex];
    else return &_multiEvents[orderIndex - MULTI_EVENTS_INDEX_SHIFT];
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(SpecReaction *reaction)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

#ifdef PARALLEL
#pragma omp critical
    {
#endif // PARALLEL
#ifdef PRINT
        std::cout << "Add ";
        reaction->info();
#endif // PRINT
        _events[RT].add(reaction);
#ifdef PARALLEL
    }
#endif // PARALLEL

    updateRate(reaction->rate());
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(SpecReaction *reaction, bool clearMemory)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

    updateRate(-reaction->rate());

#ifdef PARALLEL
#pragma omp critical
    {
#endif // PARALLEL
#ifdef PRINT
        std::cout << "Remove reaction " << reaction->name() << "(" << RT << ") [" << reaction << "]" << std::endl;
#endif // PRINT
        _events[RT].remove(reaction, clearMemory);
#ifdef PARALLEL
    }
#endif // PARALLEL
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::addMul(UbiquitousReaction *reaction, uint n)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

#ifdef PARALLEL
#pragma omp critical
    {
#endif // PARALLEL
#ifdef PRINT
        std::cout << "Add multi ";
        reaction->info();
#endif // PRINT
        _multiEvents[RT].add(reaction, n);
#ifdef PARALLEL
    }
#endif // PARALLEL

    updateRate(reaction->rate() * n);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::removeMul(UbiquitousReaction *reaction, uint n)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

    updateRate(-reaction->rate() * n);

#ifdef PARALLEL
#pragma omp critical
    {
#endif // PARALLEL
#ifdef PRINT
        std::cout << "Remove multi ";
        reaction->info();
#endif // PRINT
        _multiEvents[RT].remove(reaction, n);
#ifdef PARALLEL
    }
#endif // PARALLEL
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
