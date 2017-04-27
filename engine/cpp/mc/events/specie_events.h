#ifndef SPECIE_EVENTS_H
#define SPECIE_EVENTS_H

#include "events_wrapper.h"
#include "events_container.h"

namespace vd
{

class SpecieEvents : public EventsWrapper<EventsContainer>
{
public:
    SpecieEvents(Slice *parent);

    void add(SpecReaction *event);
    void remove(SpecReaction *event);
};

}

#endif // SPECIEEVENTS_H
