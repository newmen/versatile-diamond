#ifndef EVENTS_CONTAINER_H
#define EVENTS_CONTAINER_H

#include <unordered_map>
#include <omp.h>
#include "base_events_container.h"

namespace vd
{

class EventsContainer : public BaseEventsContainer
{
    std::unordered_map<Reaction *, uint> _positions;

public:
    void add(Reaction *event);
    void remove(Reaction *event);
};

}

#endif // EVENTS_CONTAINER_H
