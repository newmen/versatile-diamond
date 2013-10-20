#include "events_container.h"

#include <assert.h>

namespace vd
{

EventsContainer::~EventsContainer()
{
}

void EventsContainer::add(Reaction *event)
{
    assert(_positions.find(event) == _positions.end());

    _events.push_back(event);
    _positions[event] = _events.size() - 1;
}

void EventsContainer::remove(Reaction *event)
{
    auto curr = _positions.find(event);
    assert(curr != _positions.end());

    Reaction *last = removeAndGetLast(curr->second);
    if (last) _positions[last] = curr->second;

    _positions.erase(curr);
}

}
