#include "events_container.h"

#include <assert.h>

namespace vd
{

void EventsContainer::add(SpecReaction *event)
{
    assert(_positions.find(event) == _positions.end());

    _positions[event] = _events.size();
    _events.push_back(event);
}

void EventsContainer::remove(SpecReaction *event)
{
    assert(event);

    auto curr = _positions.find(event);
    assert(curr != _positions.end());

    SpecReaction *last = static_cast<SpecReaction *>(exchangeToLast(curr->second));
    if (last) _positions[last] = curr->second;

    _positions.erase(curr);

    assert(_events.size() == _positions.size());
}

}
