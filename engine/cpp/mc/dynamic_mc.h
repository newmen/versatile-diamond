#ifndef MC_H
#define MC_H

//#include <parallel/algorithm> // __gnu_parallel::sort
#include <algorithm> // std::sort
#include <cmath>
#include <functional>
#include <vector>
#include "../tools/steps_serializer.h"
#include "events/events_container.h"
#include "events/multi_events_container.h"
#include "base_mc.h"

namespace vd
{

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
class DynamicMC : public BaseMC<EVENTS_NUM, MULTI_EVENTS_NUM>
{
    enum : ushort { MULTI_EVENTS_INDEX_SHIFT = 1000 }; // for #compareContainers()

    double _totalRate = 0;

    EventsContainer _events[EVENTS_NUM];
    MultiEventsContainer _multiEvents[MULTI_EVENTS_NUM];
    std::vector<uint> _order;

public:
    DynamicMC();

    void sort() final;

#ifdef SERIALIZE
    StepsSerializer::Dict counts();
#endif // SERIALIZE

    double totalRate() const { return _totalRate; }

    void add(ushort index, SpecReaction *reaction) final;
    void remove(ushort index, SpecReaction *reaction) final;

    void add(ushort index, UbiquitousReaction *reaction, ushort n) final;
    void remove(ushort index, UbiquitousReaction *templateReaction, ushort n) final;
    void removeAll(ushort index, UbiquitousReaction *templateReaction) final;
    bool check(ushort index, Atom *target) final;

#ifndef NDEBUG
    void doOneOfOne(ushort rt);
    void doLastOfOne(ushort rt);

    void doOneOfMul(ushort rt);
    void doOneOfMul(ushort rt, int x, int y, int z);
    void doLastOfMul(ushort rt);
#endif // NDEBUG

protected:
    Reaction *mostProbablyEvent(double r) final;

private:
    DynamicMC(const DynamicMC &) = delete;
    DynamicMC(DynamicMC &&) = delete;
    DynamicMC &operator = (const DynamicMC &) = delete;
    DynamicMC &operator = (DynamicMC &&) = delete;

    void recountTotalRate();
    void updateRate(double r)
    {
        _totalRate += r;
    }

    inline BaseEventsContainer *events(uint orderIndex);
    inline BaseEventsContainer *correspondEvents(uint orderValue);
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::DynamicMC() : _order(EVENTS_NUM + MULTI_EVENTS_NUM)
{
    static_assert(EVENTS_NUM < MULTI_EVENTS_INDEX_SHIFT, "MULTI_EVENTS_INDEX_SHIFT too small, need to increase it value");

    int i = 0;
    for (; i < EVENTS_NUM; ++i) _order[i] = i;
    for (int j = 0; j < MULTI_EVENTS_NUM; ++j) _order[i + j] = j + MULTI_EVENTS_INDEX_SHIFT;

#if defined(PRINT) || defined(MC_PRINT)
    debugPrint([&](IndentStream &os) {
        os << "MC::MC() inited with order: " << std::endl;
        for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
        {
            os << i << "-" << _order[i] << std::endl;
        }
    });
#endif // PRINT || MC_PRINT
}

#ifdef SERIALIZE
template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
StepsSerializer::Dict DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::counts()
{
    StepsSerializer::Dict result;
    for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
    {
        auto evs = events(i);
        uint size = evs->size();
        if (size > 0)
        {
            result[evs->name()] = size;
        }
    }
    return result;
}
#endif // SERIALIZE

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::recountTotalRate()
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
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::sort()
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
BaseEventsContainer *DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::events(uint index)
{
    return correspondEvents(_order[index]);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
BaseEventsContainer *DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::correspondEvents(uint orderValue)
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
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(ushort index, SpecReaction *reaction)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(reaction, "Add", "one");
#endif // PRINT || MC_PRINT

    assert(index < EVENTS_NUM);

    _events[index].add(reaction);
    updateRate(reaction->rate());
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(ushort index, SpecReaction *reaction)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(reaction, "Remove", "one");
#endif // PRINT || MC_PRINT

    assert(index < EVENTS_NUM);

    updateRate(-reaction->rate());
    _events[index].remove(reaction);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::add(ushort index, UbiquitousReaction *reaction, ushort n)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(reaction, "Add", "multi", n);
#endif // PRINT || MC_PRINT

    assert(index < MULTI_EVENTS_NUM);
    assert(n < reaction->target()->valence());

    _multiEvents[index].add(reaction, n);
    updateRate(reaction->rate() * n);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::remove(ushort index, UbiquitousReaction *templateReaction, ushort n)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(templateReaction, "Remove", "multi", n);
#endif // PRINT || MC_PRINT

    assert(index < MULTI_EVENTS_NUM);
    assert(n < templateReaction->target()->valence());

    updateRate(-templateReaction->rate() * n);
    _multiEvents[index].remove(templateReaction->target(), n);
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::removeAll(ushort index, UbiquitousReaction *templateReaction)
{
    assert(index < MULTI_EVENTS_NUM);
    uint n = _multiEvents[index].removeAll(templateReaction->target());
    if (n > 0)
    {
#if defined(PRINT) || defined(MC_PRINT)
        printReaction(templateReaction, "Remove all", "multi", n);
#endif // PRINT || MC_PRINT

        assert(n < templateReaction->target()->valence());
        updateRate(-templateReaction->rate() * n);
    }
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
bool DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::check(ushort index, Atom *target)
{
    assert(index < MULTI_EVENTS_NUM);
    return _multiEvents[index].check(target);
}

#ifndef NDEBUG
template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfOne(ushort rt)
{
    assert(rt < EVENTS_NUM);
    _events[rt].selectEvent(0)->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doLastOfOne(ushort rt)
{
    assert(rt < EVENTS_NUM);
    _events[rt].selectEvent((_events[rt].size() - 0.5) * _events[rt].oneRate())->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfMul(ushort rt)
{
    assert(rt < MULTI_EVENTS_NUM);
    _multiEvents[rt].selectEvent(0.0)->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doOneOfMul(ushort rt, int x, int y, int z)
{
    assert(rt < MULTI_EVENTS_NUM);
    auto crd = int3(x, y, z);
    _multiEvents[rt].selectEventByCoords(crd)->doIt();
}

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
void DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::doLastOfMul(ushort rt)
{
    assert(rt < MULTI_EVENTS_NUM);
    _multiEvents[rt].selectEvent((_multiEvents[rt].size() - 0.5) * _multiEvents[rt].oneRate())->doIt();
}
#endif // NDEBUG

template <ushort EVENTS_NUM, ushort MULTI_EVENTS_NUM>
Reaction *DynamicMC<EVENTS_NUM, MULTI_EVENTS_NUM>::mostProbablyEvent(double r)
{
#if defined(PRINT) || defined(MC_PRINT)
    debugPrint([&](IndentStream &os) {
        os << "MC::mostProbablyEvent()\n";
        os << "Random number: " << r << "\n";
    });
#endif // PRINT || MC_PRINT

    Reaction *event = nullptr;
    double passRate = 0;
    for (int i = 0; i < EVENTS_NUM + MULTI_EVENTS_NUM; ++i)
    {
        BaseEventsContainer *currentEvents = events(i);
        double cr = currentEvents->commonRate();
        if (r < cr + passRate)
        {
#if defined(PRINT) || defined(MC_PRINT)
            debugPrint([&](IndentStream &os) {
                os << "event " << i;
            });
#endif // PRINT || MC_PRINT

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

}

#endif // MC_H
