#ifndef MC_H
#define MC_H

//#include <parallel/algorithm> // __gnu_parallel::sort
#include <algorithm> // std::sort
#include <cmath>
#include <functional>
#include <vector>
#include "common_mc_data.h"
#include "events_container.h"
#include "multi_events_container.h"

namespace vd
{

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
class MC
{
    enum : ushort { MULTI_EVENTS_INDEX_SHIFT = 1000 }; // for #compareContainers()

    double _totalRate = 0;
    double _totalTime = 0;

    EventsContainer _events[EVENTS_NUM];
    MultiEventsContainer _multiEvents[MULTI_EVENTS_NUM];
    std::vector<uint> _order;

public:
    MC();

    void initCounter(CommonMCData *data) const;

    void sort();

    double doRandom(CommonMCData *data);
    double totalRate() const { return _totalRate; }
    double totalTime() const { return _totalTime; }

    void add(ushort index, SpecReaction *reaction);
    void remove(ushort index, SpecReaction *reaction);

    void add(ushort index, UbiquitousReaction *reaction, ushort n);
    void remove(ushort index, UbiquitousReaction *templateReaction, ushort n);
    void removeAll(ushort index, UbiquitousReaction *templateReaction);
    bool check(ushort index, Atom *target);

#ifndef NDEBUG
    void doOneOfOne(ushort rt);
    void doLastOfOne(ushort rt);

    void doOneOfMul(ushort rt);
    void doOneOfMul(ushort rt, int x, int y, int z);
    void doLastOfMul(ushort rt);
#endif // NDEBUG

private:
    MC(const MC &) = delete;
    MC(MC &&) = delete;
    MC &operator = (const MC &) = delete;
    MC &operator = (MC &&) = delete;

    Reaction *mostProbablyEvent(double r);

    double increaseTime(CommonMCData *data);
    void recountTotalRate();
    void updateRate(double r)
    {
        _totalRate += r;
    }

    inline BaseEventsContainer *events(uint orderIndex);
    inline BaseEventsContainer *correspondEvents(uint orderValue);

#ifdef PRINT
    void printReaction(Reaction *reaction, std::string action, std::string type, uint n = 1);
#endif // PRINT
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
MC<EVENTS_NUM, MULTI_EVENTS_NUM>::MC() : _order(EVENTS_NUM + MULTI_EVENTS_NUM)
{
    static_assert(EVENTS_NUM < MULTI_EVENTS_INDEX_SHIFT, "MULTI_EVENTS_INDEX_SHIFT too small, need to increase it value");

    int i = 0;
    for (; i < EVENTS_NUM; ++i) _order[i] = i;
    for (int j = 0; j < MULTI_EVENTS_NUM; ++j) _order[i + j] = j + MULTI_EVENTS_INDEX_SHIFT;

#ifdef PRINT
    debugPrint([&](IndentStream &os) {
        os << "MC::MC() inited with order: " << std::endl;
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
double MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doRandom(CommonMCData *data)
{
#ifdef PRINT
    debugPrint([&](IndentStream &os) {
        os << "MC::doRandom()\n";
        os << "Rate: " << totalRate() << " % time: " << totalTime() << "\n";
        os << "Current sizes: " << std::endl;
        for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
        {
            os << i << "-" << _order[i] << ".. " << events(i)->size() << " -> " << events(i)->commonRate() << "\n";
        }
    });
#endif // PRINT

    double r = data->rand(totalRate());
    Reaction *event = mostProbablyEvent(r);
    if (event)
    {
#ifdef PRINT
        debugPrint([&](IndentStream &os) {
            os << event->name();
        });
#endif // PRINT

        data->counter()->inc(event);
        event->doIt();
        return increaseTime(data);
    }
    else
    {
#ifdef PRINT
        debugPrint([&](IndentStream &os) {
            os << "Event not found! Recount and sort!";
        });
#endif // PRINT

        recountTotalRate();
        sort();

        if (totalRate() == 0)
        {
            return -1;
        }
        else
        {
            return doRandom(data);
        }
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
double MC<EVENTS_NUM, MULTI_EVENTS_NUM>::increaseTime(CommonMCData *data)
{
    double r = data->rand(1.0);
    double dt = -log(r) / totalRate();
    _totalTime += dt;

    return dt;
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
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(ushort index, SpecReaction *reaction)
{
#ifdef PRINT
    printReaction(reaction, "Add", "one");
#endif // PRINT

    assert(index < EVENTS_NUM);

    _events[index].add(reaction);
    updateRate(reaction->rate());
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(ushort index, SpecReaction *reaction)
{
#ifdef PRINT
    printReaction(reaction, "Remove", "one");
#endif // PRINT

    assert(index < EVENTS_NUM);

    updateRate(-reaction->rate());
    _events[index].remove(reaction);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(ushort index, UbiquitousReaction *reaction, ushort n)
{
#ifdef PRINT
    printReaction(reaction, "Add", "multi", n);
#endif // PRINT

    assert(index < MULTI_EVENTS_NUM);
    assert(n < reaction->target()->valence());

    _multiEvents[index].add(reaction, n);
    updateRate(reaction->rate() * n);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(ushort index, UbiquitousReaction *templateReaction, ushort n)
{
#ifdef PRINT
    printReaction(templateReaction, "Remove", "multi", n);
#endif // PRINT

    assert(index < MULTI_EVENTS_NUM);
    assert(n < templateReaction->target()->valence());

    updateRate(-templateReaction->rate() * n);
    _multiEvents[index].remove(templateReaction->target(), n);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::removeAll(ushort index, UbiquitousReaction *templateReaction)
{
    assert(index < MULTI_EVENTS_NUM);
    uint n = _multiEvents[index].removeAll(templateReaction->target());
    if (n > 0)
    {
        assert(n < templateReaction->target()->valence());
        updateRate(-templateReaction->rate() * n);
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
bool MC<EVENTS_NUM, MULTI_EVENTS_NUM>::check(ushort index, Atom *target)
{
    assert(index < MULTI_EVENTS_NUM);
    return _multiEvents[index].check(target);
}

#ifndef NDEBUG
template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfOne(ushort rt)
{
    assert(rt < EVENTS_NUM);
    _events[rt].selectEvent(0)->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doLastOfOne(ushort rt)
{
    assert(rt < EVENTS_NUM);
    _events[rt].selectEvent((_events[rt].size() - 0.5) * _events[rt].oneRate())->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfMul(ushort rt)
{
    assert(rt < MULTI_EVENTS_NUM);
    _multiEvents[rt].selectEvent(0.0)->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfMul(ushort rt, int x, int y, int z)
{
    auto crd = int3(x, y, z);
    _multiEvents[rt].selectEventByCoords(crd)->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::doLastOfMul(ushort rt)
{
    assert(rt < MULTI_EVENTS_NUM);
    _multiEvents[rt].selectEvent((_multiEvents[rt].size() - 0.5) * _multiEvents[rt].oneRate())->doIt();
}
#endif // NDEBUG

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
Reaction *MC<EVENTS_NUM, MULTI_EVENTS_NUM>::mostProbablyEvent(double r)
{
#ifdef PRINT
    debugPrint([&](IndentStream &os) {
        os << "MC::mostProbablyEvent()\n";
        os << "Random number: " << r << "\n";
    });
#endif // PRINT

    Reaction *event = nullptr;
    double passRate = 0;
    for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
    {
        BaseEventsContainer *currentEvents = events(i);
        double cr = currentEvents->commonRate();
        if (r < cr + passRate)
        {
#ifdef PRINT
            debugPrint([&](IndentStream &os) {
                os << "event " << i;
            });
#endif // PRINT

            event = currentEvents->selectEvent(r - passRate);
            break;
        }
        else
        {
            passRate += cr;
        }
    }

    return event;
}

#ifdef PRINT
template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void MC<EVENTS_NUM, MULTI_EVENTS_NUM>::printReaction(Reaction *reaction, std::string action, std::string type, uint n)
{
    debugPrint([&](IndentStream &os) {
        os << "MC::printReaction() ";
        os << action << " ";
        if (n > 1)
        {
            os << n << " ";
        }
        os << type << " (" << reaction->type() << ") ";
        reaction->info(os);
    });
}
#endif // PRINT

}

#endif // MC_H
