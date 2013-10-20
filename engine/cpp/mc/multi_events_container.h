#ifndef MULTI_EVENTS_CONTAINER_H
#define MULTI_EVENTS_CONTAINER_H

#include <unordered_map>
#include <omp.h>
#include "base_events_container.h"

namespace vd
{

class MultiEventsContainer : public BaseEventsContainer
{
    std::unordered_multimap<Reaction *, uint> _positions;

public:
    ~MultiEventsContainer();

    void add(Reaction *event, uint n);
    void remove(Reaction *event, uint n);
};

}

#endif // MULTI_EVENTS_CONTAINER_H
