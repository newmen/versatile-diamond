#ifndef EVENTS_CONTAINER_H
#define EVENTS_CONTAINER_H

#include <unordered_map>
#include "../reactions/spec_reaction.h"
#include "base_events_container.h"

namespace vd
{

class EventsContainer : public BaseEventsContainer
{
    std::unordered_map<SpecReaction *, uint> _positions;

public:
    void add(SpecReaction *event);
    void remove(SpecReaction *event);
};

}

#endif // EVENTS_CONTAINER_H
