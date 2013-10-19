#ifndef BASE_EVENTS_CONTAINER_H
#define BASE_EVENTS_CONTAINER_H

#include <vector>
#include "../reaction.h"

namespace vd
{

class BaseEventsContainer
{
    std::vector<Reaction *> _events;

public:
    virtual ~BaseEventsContainer();

    double commonRate() const;

protected:
    std::vector<Reaction *> &events() { return _events; }

    template <class M>
    inline void remove(M *mirror, Reaction *event);
};

template <class M>
void BaseEventsContainer::remove(M *positions, Reaction *event)
{
    auto curr = positions->find(event);
    assert(curr != positions->end());

    Reaction *last = *_events.rbegin();
    _events.pop_back();

    auto it = _events.begin() + curr->second;
    delete *it;
    *it = last;

    positions->insert(std::pair<Reaction *, uint>(last, curr->second));
    positions->erase(curr);
}

}

#endif // BASE_EVENTS_CONTAINER_H
