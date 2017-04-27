#ifndef ATOM_EVENTS_H
#define ATOM_EVENTS_H

#include "events_wrapper.h"
#include "multi_events_container.h"

namespace vd
{

class AtomEvents : public EventsWrapper<MultiEventsContainer>
{
public:
    AtomEvents(Slice *parent);

    void add(UbiquitousReaction *event, ushort n);
    void remove(UbiquitousReaction *event, ushort n);
    void removeAll(UbiquitousReaction *event);
};

}

#endif // ATOM_EVENTS_H
