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
    MultiEventsContainer() = default;
    ~MultiEventsContainer();

#ifndef NDEBUG
    Reaction *selectEventByCoords(const int3 &crd);
#endif // NDEBUG

    void add(UbiquitousReaction *event, ushort n);
    void remove(Atom *target, ushort n);
    uint removeAll(Atom *target);
    bool check(Atom *target);

private:
    MultiEventsContainer(const MultiEventsContainer &) = delete;
    MultiEventsContainer(MultiEventsContainer &&) = delete;
    MultiEventsContainer &operator = (const MultiEventsContainer &) = delete;
    MultiEventsContainer &operator = (MultiEventsContainer &&) = delete;

    void unlockedRemove(Atom *target, uint n);
};

}

#endif // MULTI_EVENTS_CONTAINER_H
