#ifndef MULTI_EVENTS_CONTAINER_H
#define MULTI_EVENTS_CONTAINER_H

#include <map>
#include <omp.h>
#include "../reactions/multi_reaction.h"
#include "base_events_container.h"

namespace vd
{

class MultiEventsContainer : public BaseEventsContainer
{
    std::multimap<Atom *, uint> _positions;

public:
    ~MultiEventsContainer();

    void add(MultiReaction *event, uint n);
    void remove(MultiReaction *event, uint n);
};

}

#endif // MULTI_EVENTS_CONTAINER_H
