#ifndef MC_H
#define MC_H

//#include <parallel/algorithm> // __gnu_parallel::sort
#include <algorithm> // std::sort
#include <chrono>
#include <random>
#include <vector>
#include "common_mc_data.h"
#include "events_container.h"
#include "multi_events_container.h"

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

//#ifdef PRINT
#include <iostream>
//#endif // PRINT

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

    void doRandom(CommonMCData *data);
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

    inline BaseEventsContainer *events(uint orderIndex);
    inline BaseEventsContainer *correspondEvents(uint orderValue);
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
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doRandom(CommonMCData *data)
{
#ifdef PRINT
#ifdef PARALLEL
#pragma omp master
#pragma omp critical (print)
#endif // PARALLEL
    std::cout << " > " << totalRate() << std::endl;
#ifdef PARALLEL
#pragma omp barrier
#endif // PARALLEL
#endif // PRINT

#ifdef PRINT
#ifdef PARALLEL
#pragma omp master
#pragma omp critical (print)
#endif // PARALLEL
    {
        std::cout << "Current sizes: " << std::endl;
        for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
        {
            std::cout << i << "-" << _order[i] << ".. " << events(i)->size() << " -> " << events(i)->commonRate() << std::endl;
        }
    }
#endif // PRINT

    std::uniform_real_distribution<double> distribution(0.0, totalRate());
    Reaction *event = nullptr;

    double r = 0;
#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
    r = distribution(_randomGenerator);

#ifdef PRINT
#ifdef PARALLEL
#pragma omp critical (print)
#endif // PARALLEL
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
#ifdef PARALLEL
#pragma omp critical (print)
#endif // PARALLEL
            std::cout << "Event " << i << " => ";
#endif // PRINT

            event = currentEvents->selectEvent(r - passRate);
            data->checkSame(event);
            break;
        }
        else
        {
            passRate += cr;
        }
    }

#ifdef PRINT
#ifdef PARALLEL
#pragma omp critical (print)
#endif // PARALLEL
    {
#ifdef PARALLEL
        std::cout << omp_get_thread_num() << " selects ";
#endif // PARALLEL
        if (!event) std::cout << "null";
        else
        {
            if (!event->anchor()->lattice()) std::cout << "amorph";
            else std::cout << event->anchor()->lattice()->coords();

            std::cout << " which is";
            if (!data->isSame()) std::cout << " not";
            std::cout << " same";
        }
        std::cout << std::endl;
    }
#endif // PRINT

#ifdef PARALLEL
#pragma omp barrier
#endif // PARALLEL

    if (!event)
    {
        data->noEvent();
    }
    else if (!data->isSame())
    {
        event->doIt();
    }

#ifdef PARALLEL
#pragma omp barrier
#endif // PARALLEL

#ifdef PARALLEL
#pragma omp master
#endif // PARALLEL
    {
        if (data->wasntFound())
        {
#ifdef PRINT
            std::cout << "Event not found! Recount && Resort" << std::endl;
#endif // PRINT

            recountTotalRate();
        }

        if (data->wasntFound() || data->hasSameSite())
        {
            sort();
        }

        data->reset();
    }
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
        BaseEventsContainer *ae = correspondEvents(a);
        BaseEventsContainer *be = correspondEvents(b);

        return ae->commonRate() > be->commonRate();
    };

    std::sort(_order.begin(), _order.end(), compare);
//    __gnu_parallel::sort(_order.begin(), _order.end(), compare);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
BaseEventsContainer *MC<EVENTS_NUM, MULTI_EVENTS_NUM>::events(uint index)
{
    uint orderValue = _order[index];
    return correspondEvents(orderValue);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
BaseEventsContainer *MC<EVENTS_NUM, MULTI_EVENTS_NUM>::correspondEvents(uint orderValue)
{
    if (orderValue < MULTI_EVENTS_INDEX_SHIFT)
    {
        return &_events[orderValue];
    }
    else
    {
        return &_multiEvents[orderValue - MULTI_EVENTS_INDEX_SHIFT];
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(SpecReaction *reaction)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
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
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(SpecReaction *reaction, bool clearMemory)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

    updateRate(-reaction->rate());

#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
    {
#ifdef PRINT
        std::cout << "Remove reaction " << reaction->name() << "(" << RT << ") [" << reaction << "]" << std::endl;
#endif // PRINT
        _events[RT].remove(reaction, clearMemory);
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::addMul(UbiquitousReaction *reaction, uint n)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
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
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::removeMul(UbiquitousReaction *reaction, uint n)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

    updateRate(-reaction->rate() * n);

#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
    {
#ifdef PRINT
        std::cout << "Remove multi ";
        reaction->info();
#endif // PRINT
        _multiEvents[RT].remove(reaction->target(), n);
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfOne()
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");
    _events[RT].selectEvent(0)->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfMul()
{
    static_assert(RT < MULTI_EVENTS_NUM, "Wrong reaction ID");
    _multiEvents[RT].selectEvent(0)->doIt();
}

}

#endif // MC_H
