#include "events_container.h"

namespace vd
{

void EventsContainer::add(SpecReaction *event)
{
    assert(_positions.find(event) == _positions.cend());

    _positions[event] = _events.size();
    _events.push_back(event);
}

void EventsContainer::remove(SpecReaction *event)
{
    assert(event);
    auto curr = _positions.find(event);
    assert(curr != _positions.cend());

    SpecReaction *last = exchangeToLast<SpecReaction>(curr->second);
    if (last) _positions[last] = curr->second;

    _positions.erase(curr);
    assert(_events.size() == _positions.size());
}

}
