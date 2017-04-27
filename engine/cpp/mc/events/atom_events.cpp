#include "atom_events.h"

namespace vd
{

AtomEvents::AtomEvents(Slice *parent) : EventsWrapper<MultiEventsContainer>(parent)
{
}

void AtomEvents::add(UbiquitousReaction *event, ushort n)
{
    MultiEventsContainer::add(event, n);
    updateParentRate(event, n);
}

void AtomEvents::remove(UbiquitousReaction *event, ushort n)
{
    MultiEventsContainer::remove(event->target(), n);
    updateParentRate(event, -n);
}

void AtomEvents::removeAll(UbiquitousReaction *event)
{
    uint n = MultiEventsContainer::removeAll(event->target());
    if (n > 0)
    {
        assert(n < event->target()->valence());
        updateParentRate(event, -n);
    }
}

}
