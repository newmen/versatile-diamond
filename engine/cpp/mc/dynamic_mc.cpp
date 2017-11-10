#include "dynamic_mc.h"

namespace vd
{

DynamicMC::DynamicMC(ushort eventsNum, ushort multiEventsNum) :
    _events(eventsNum), _multiEvents(multiEventsNum), _order(eventsNum + multiEventsNum)
{
    assert(eventsNum < MULTI_EVENTS_INDEX_SHIFT);

    int i = 0;
    for (; i < eventsNum; ++i) _order[i] = i;
    for (int j = 0; j < multiEventsNum; ++j) _order[i + j] = j + MULTI_EVENTS_INDEX_SHIFT;

#if defined(PRINT) || defined(MC_PRINT)
    debugPrint([&](IndentStream &os) {
        os << "MC::MC() inited with order: " << std::endl;
        for (int i = 0; i < eventsNum + multiEventsNum; ++i)
        {
            os << i << "-" << _order[i] << std::endl;
        }
    });
#endif // PRINT || MC_PRINT
}

#ifdef JSONLOG
JSONStepsLogger::Dict DynamicMC::counts()
{
    JSONStepsLogger::Dict result;
    for (int i = 0; i < eventsNum + multiEventsNum; ++i)
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
#endif // JSONLOG

void DynamicMC::recountTotalRate()
{
    _totalRate = 0;
    for (const EventsContainer &event : _events)
    {
        _totalRate += event.commonRate();
    }
    for (const MultiEventsContainer &event : _multiEvents)
    {
        _totalRate += event.commonRate();
    }
}

void DynamicMC::sort()
{
    if (!DISABLE_MC_SORT)
    {
        auto compare = [this](uint a, uint b) {
            BaseEventsContainer *ae = correspondEvents(a);
            BaseEventsContainer *be = correspondEvents(b);
            return ae->commonRate() > be->commonRate();
        };

        std::sort(_order.begin(), _order.end(), compare);
//        __gnu_parallel::sort(_order.begin(), _order.end(), compare);
    }
}

void DynamicMC::halfSort()
{
    if (!DISABLE_MC_SORT)
    {
        assert(_order.size() > 1);
        for (uint i = 0; i < _order.size() - 1; ++i)
        {
            uint a = _order[i], b = _order[i+1];
            BaseEventsContainer *ae = correspondEvents(a);
            BaseEventsContainer *be = correspondEvents(b);
            if (ae->commonRate() < be->commonRate())
            {
                _order[i] = b;
                _order[i+1] = a;
            }
        }
    }
}

BaseEventsContainer *DynamicMC::events(uint index)
{
    return correspondEvents(_order[index]);
}

BaseEventsContainer *DynamicMC::correspondEvents(uint orderValue)
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

void DynamicMC::add(ushort index, SpecReaction *reaction)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(reaction, "Add", "one");
#endif // PRINT || MC_PRINT

    assert(index < _events.size());

    _events[index].add(reaction);
    updateRate(reaction->rate());
}

void DynamicMC::remove(ushort index, SpecReaction *reaction)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(reaction, "Remove", "one");
#endif // PRINT || MC_PRINT

    assert(index < _events.size());
    updateRate(-reaction->rate());
    _events[index].remove(reaction);
}

void DynamicMC::add(ushort index, UbiquitousReaction *reaction, ushort n)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(reaction, "Add", "multi", n);
#endif // PRINT || MC_PRINT

    assert(index < _multiEvents.size());
    assert(n < reaction->target()->valence());
    _multiEvents[index].add(reaction, n);
    updateRate(reaction->rate() * n);
}

void DynamicMC::remove(ushort index, UbiquitousReaction *templateReaction, ushort n)
{
#if defined(PRINT) || defined(MC_PRINT)
    printReaction(templateReaction, "Remove", "multi", n);
#endif // PRINT || MC_PRINT

    assert(index < _multiEvents.size());
    assert(n < templateReaction->target()->valence());
    updateRate(-templateReaction->rate() * n);
    _multiEvents[index].remove(templateReaction->target(), n);
}

void DynamicMC::removeAll(ushort index, UbiquitousReaction *templateReaction)
{
    assert(index < _multiEvents.size());
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

bool DynamicMC::check(ushort index, Atom *target)
{
    assert(index < _multiEvents.size());
    return _multiEvents[index].check(target);
}

#ifndef NDEBUG
void DynamicMC::doOneOfOne(ushort rt)
{
    assert(rt < _events.size());
    _events[rt].selectEvent(0)->doIt();
}

void DynamicMC::doLastOfOne(ushort rt)
{
    assert(rt < _events.size());
    _events[rt].selectEvent((_events[rt].size() - 0.5) * _events[rt].oneRate())->doIt();
}

void DynamicMC::doOneOfMul(ushort rt)
{
    assert(rt < _multiEvents.size());
    _multiEvents[rt].selectEvent(0.0)->doIt();
}

void DynamicMC::doOneOfMul(ushort rt, int x, int y, int z)
{
    assert(rt < _multiEvents.size());
    auto crd = int3(x, y, z);
    _multiEvents[rt].selectEventByCoords(crd)->doIt();
}

void DynamicMC::doLastOfMul(ushort rt)
{
    assert(rt < _multiEvents.size());
    _multiEvents[rt].selectEvent((_multiEvents[rt].size() - 0.5) * _multiEvents[rt].oneRate())->doIt();
}
#endif // NDEBUG

uint DynamicMC::totalEventsNum() const
{
    return _events.size() + _multiEvents.size();
}

Reaction *DynamicMC::mostProbablyEvent(double r)
{
#if defined(PRINT) || defined(MC_PRINT)
    debugPrint([&](IndentStream &os) {
        os << "MC::mostProbablyEvent()\n";
        os << "Random number: " << r << "\n";
    });
#endif // PRINT || MC_PRINT

    Reaction *event = nullptr;
    double passRate = 0;
    for (uint i = 0; i < totalEventsNum(); ++i)
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
