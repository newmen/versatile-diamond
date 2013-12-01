#include "events_container.h"

#include <assert.h>

namespace vd
{

void EventsContainer::add(SpecReaction *event)
{
#ifdef PARALLEL
    lock([this, event]() {
#endif // PARALLEL

        assert(_positions.find(event) == _positions.cend());

        _positions[event] = _events.size();
        _events.push_back(event);

#ifdef PARALLEL
    });
#endif // PARALLEL
}

void EventsContainer::remove(SpecReaction *event)
{
    assert(event);

#ifdef PARALLEL
    lock([this, event]() {
#endif // PARALLEL

        auto curr = _positions.find(event);
        assert(curr != _positions.cend());

        SpecReaction *last = static_cast<SpecReaction *>(exchangeToLast(curr->second));
        if (last) _positions[last] = curr->second;

        _positions.erase(curr);

        assert(_events.size() == _positions.size());

#ifdef PARALLEL
    });
#endif // PARALLEL
}

}
