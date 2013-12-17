#ifndef MULTI_EVENTS_CONTAINER_H
#define MULTI_EVENTS_CONTAINER_H

#include <unordered_map>
#include "../reactions/ubiquitous_reaction.h"
#include "base_events_container.h"

namespace vd
{

class MultiEventsContainer : public BaseEventsContainer
{
    std::unordered_multimap<Atom *, uint> _positions;

public:
    ~MultiEventsContainer();

    void add(UbiquitousReaction *event, uint n);
    void remove(Atom *target, uint n);
    uint removeAll(Atom *target);
    bool check(Atom *target);

private:
    void unlockedRemove(Atom *target, uint n);
};

}

#endif // MULTI_EVENTS_CONTAINER_H
