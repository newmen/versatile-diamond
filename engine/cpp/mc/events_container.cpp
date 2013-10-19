#include "events_container.h"

namespace vd
{

void EventsContainer::add(Reaction *event)
{
    assert(_positions.find(event) == _positions.end());

    events().push_back(event);
    _positions[event] = events().size() - 1;
}

void EventsContainer::remove(Reaction *event)
{
    BaseEventsContainer::remove(&_positions, event);
}

}
