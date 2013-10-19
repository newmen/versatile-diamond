#include "multi_events_container.h"

namespace vd
{

void MultiEventsContainer::add(Reaction *event, uint n)
{
    for (uint i = 0; i < n; ++i)
    {
        events().push_back(event);
        _positions.insert(std::pair<Reaction *, uint>(event, events().size() - 1));
    }
}

void MultiEventsContainer::remove(Reaction *event, uint n)
{
    for (uint i = 0; i < n; ++i)
    {
        BaseEventsContainer::remove(&_positions, event);
    }
}

}
