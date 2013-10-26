#include "events_container.h"

#include <assert.h>

namespace vd
{

void EventsContainer::add(SingleReaction *event)
{
    assert(_positions.find(event) == _positions.end());

    _positions[event] = _events.size();
    _events.push_back(event);
}

void EventsContainer::remove(SingleReaction *event)
{
    assert(event);

    auto curr = _positions.find(event);
    assert(curr != _positions.end());

    SingleReaction *last = static_cast<SingleReaction *>(exchangeToLast(curr->second));
    if (last) _positions[last] = curr->second;

    _positions.erase(curr);
    delete event;

    assert(_events.size() == _positions.size());
}

}
