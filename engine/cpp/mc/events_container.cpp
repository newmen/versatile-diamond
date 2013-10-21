#include "events_container.h"

#include <assert.h>

namespace vd
{

void EventsContainer::add(Reaction *event)
{
    assert(_positions.find(event) == _positions.end());

    _events.push_back(event);
    _positions[event] = _events.size() - 1;
}

void EventsContainer::remove(Reaction *event)
{
    assert(event);

    auto curr = _positions.find(event);
    assert(curr != _positions.end());

    Reaction *last = exchangeToLast(curr->second);
    if (last) _positions[last] = curr->second;

    _positions.erase(curr);
//    delete event;

    assert(_events.size() == _positions.size());
}

}
