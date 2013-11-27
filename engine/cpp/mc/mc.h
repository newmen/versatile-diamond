#ifndef MC_H
#define MC_H

//#include <parallel/algorithm> // __gnu_parallel::sort
#include <algorithm> // std::sort
#include <cmath>
#include <vector>
#include "common_mc_data.h"
#include "events_container.h"
#include "multi_events_container.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

// for #compareContainers()
#define MULTI_EVENTS_INDEX_SHIFT 1000

namespace vd
{

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
class MC
{
    double _totalRate = 0;
    double _totalTime = 0;

    EventsContainer _events[EVENTS_NUM];
    MultiEventsContainer _multiEvents[MULTI_EVENTS_NUM];
    std::vector<uint> _order;

public:
    MC();

    void initCounter(CommonMCData *data) const;

    void sort();

    void doRandom(CommonMCData *data);
    double totalRate() const { return _totalRate; }
    double totalTime() const { return _totalTime; }

    template <ushort RT> void add(SpecReaction *reaction);
    template <ushort RT> void remove(SpecReaction *reaction);

    template <ushort RT> void addMul(UbiquitousReaction *reaction, uint n);
    template <ushort RT> void removeMul(UbiquitousReaction *reaction, uint n);

#ifdef DEBUG
    template <ushort RT> void doOneOfOne();
//    template <ushort RT> void doOneOfOne();

    template <ushort RT> void doOneOfMul();
    template <ushort RT> void doOneOfMul(int x, int y, int z);
#endif // DEBUG

private:
    void increaseTime(CommonMCData *data);
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

    int i = 0;
    for (; i < EVENTS_NUM; ++i) _order[i] = i;
    for (int j = 0; j < MULTI_EVENTS_NUM; ++j) _order[i + j] = j + MULTI_EVENTS_INDEX_SHIFT;

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "Inited order: " << std::endl;
        for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
        {
            os << i << "-" << _order[i] << std::endl;
        }
    });
#endif // PRINT
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::initCounter(CommonMCData *data) const
{
    data->makeCounter(EVENTS_NUM + MULTI_EVENTS_NUM);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doRandom(CommonMCData *data)
{
#ifdef PRINT
#ifdef PARALLEL
#pragma omp master
#endif // PARALLEL
    debugPrint([&](std::ostream &os) {
        os << " > rate: " << totalRate() << " % time: " << totalTime();
    });

#ifdef PARALLEL
#pragma omp master
#endif // PARALLEL
    debugPrint([&](std::ostream &os) {
        os << "Current sizes: " << std::endl;
        for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
        {
            os << i << "-" << _order[i] << ".. " << events(i)->size() << " -> " << events(i)->commonRate() << std::endl;
        }
    });
#endif // PRINT

    Reaction *event = nullptr;
    double r = data->rand(totalRate());

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "Random number: " << r << "\n";
    });
#endif // PRINT

    double passRate = 0;
    for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
    {
        BaseEventsContainer *currentEvents = events(i);
        double cr = currentEvents->commonRate();
        if (r < cr + passRate)
        {
#ifdef PRINT
            debugPrint([&](std::ostream &os) {
                os << "event " << i;
            });
#endif // PRINT

            event = currentEvents->selectEvent(r - passRate);
            data->store(event);
            break;
        }
        else
        {
            passRate += cr;
        }
    }

#ifdef PARALLEL
#pragma omp barrier
#endif // PARALLEL

    if (!event)
    {
        data->setEventNotFound();
    }
    else
    {
        data->checkSame();
    }

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        if (!event) os << "null";
        else
        {
            if (!event->anchor()->lattice()) os << "amorph";
            else os << event->anchor()->lattice()->coords();

            os << " which is";
            if (!data->isSame()) os << " not";
            os << " same";
        }
    });
#endif // PRINT

#ifdef PARALLEL
#pragma omp barrier
#endif // PARALLEL

    if (event && !data->isSame())
    {
        increaseTime(data);
        data->counter()->inc(event);
        event->doIt();
    }

#ifdef PARALLEL
#pragma omp barrier
#endif // PARALLEL

#ifdef PARALLEL
#pragma omp master
#endif // PARALLEL
    {
        if (data->eventWasntFound())
        {
#ifdef PRINT
            debugPrint([&](std::ostream &os) {
                os << "Event not found! Recount";
            });
#endif // PRINT

            recountTotalRate();
        }

        if (data->eventWasntFound() || data->hasSameSite())
        {
#ifdef PRINT
            debugPrint([&](std::ostream &os) {
                os << " -> sort!";
            });
#endif // PRINT
            sort();
        }

        data->reset();
    }

#ifdef PARALLEL
#pragma omp barrier
#endif // PARALLEL
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::increaseTime(CommonMCData *data)
{
    double r = data->rand(1.0);
    double dt = -log(r) / totalRate();

#ifdef PARALLEL
#pragma omp atomic
#endif // PARALLEL
    _totalTime += dt;
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
        debugPrintWoLock([&](std::ostream &os) {
            os << "Add ";
            reaction->info(os);
        });
#endif // PRINT
        _events[RT].add(reaction);
    }

    updateRate(reaction->rate());
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(SpecReaction *reaction)
{
    static_assert(RT < EVENTS_NUM, "Wrong reaction ID");

    updateRate(-reaction->rate());

#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
    {
#ifdef PRINT
        debugPrintWoLock([&](std::ostream &os) {
            os << "Remove reaction " << reaction->name() << "(" << RT << ") [" << reaction << "]";
        });
#endif // PRINT
        _events[RT].remove(reaction);
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
        debugPrintWoLock([&](std::ostream &os) {
            os << "Add multi ";
            reaction->info(os);
        });
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
        debugPrintWoLock([&](std::ostream &os) {
            os << "Remove multi ";
            reaction->info(os);
        });
#endif // PRINT
        _multiEvents[RT].remove(reaction->target(), n);
    }
}

#ifdef DEBUG
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

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
template <ushort RT>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfMul(int x, int y, int z)
{
    auto crd = int3(x, y, z);
    _multiEvents[RT].selectEvent(crd)->doIt();
}

#endif // DEBUG

}

#endif // MC_H
