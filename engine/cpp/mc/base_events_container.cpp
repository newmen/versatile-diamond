#include "base_events_container.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

BaseEventsContainer::~BaseEventsContainer()
{
}

#ifdef DEBUG
Reaction *BaseEventsContainer::selectEvent(const int3 &crd)
{
    for (Reaction *event : _events)
    {
        if (event->anchor()->lattice() && event->anchor()->lattice()->coords() == crd)
        {
            return event;
        }
    }

    assert(true); // multi event by crd was not found
    return nullptr;
}
#endif // DEBUG

Reaction *BaseEventsContainer::selectEvent(double r)
{
    assert(_events.size() > 0);

    uint index = (uint)(r / _events.front()->rate());
    assert(index < _events.size());

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "SELECTED: " << index;
    });
#endif // PRINT

    return _events[index];
}

double BaseEventsContainer::commonRate() const
{
    return (_events.empty()) ?
                0.0 :
                _events.front()->rate() * _events.size();
}

Reaction *BaseEventsContainer::exchangeToLast(uint index)
{
    assert(index < _events.size());

    Reaction *last = _events.back();
    _events.pop_back();

    if (_events.begin() + index == _events.end())
    {
        return nullptr;
    }
    else
    {
        _events[index] = last;
        return last;
    }
}

}
