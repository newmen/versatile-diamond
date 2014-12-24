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
    EventsContainer() = default;

    void add(SpecReaction *event);
    void remove(SpecReaction *event);

private:
    EventsContainer(const EventsContainer &) = delete;
    EventsContainer(EventsContainer &&) = delete;
    EventsContainer &operator = (const EventsContainer &) = delete;
    EventsContainer &operator = (EventsContainer &&) = delete;
};

}

#endif // EVENTS_CONTAINER_H
