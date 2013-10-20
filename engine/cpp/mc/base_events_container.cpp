#include "base_events_container.h"

namespace vd
{

BaseEventsContainer::~BaseEventsContainer()
{
    for (Reaction *event : _events)
    {
        delete event;
    }
}

double BaseEventsContainer::commonRate() const
{
    return (_events.size() > 0) ?
                _events.front()->rate() * _events.size() :
                0.0;
}

Reaction *BaseEventsContainer::removeAndGetLast(uint index)
{
    assert(index < _events.size());

    Reaction *last = _events.back();
    _events.pop_back();

    auto it = _events.begin() + index;
    if (it == _events.end())
    {
        delete last;
        return 0;
    }
    else
    {
        delete *it;
        *it = last;
        return last;
    }
}

}
