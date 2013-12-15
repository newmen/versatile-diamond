#ifndef BASE_EVENTS_CONTAINER_H
#define BASE_EVENTS_CONTAINER_H

#include <vector>
#include <unordered_map>
#include "../tools/lockable.h"
#include "../reactions/reaction.h"

namespace vd
{

#ifdef PARALLEL
class BaseEventsContainer :
        public Lockable // for children classes
#else
class BaseEventsContainer
#endif // PARALLEL
{
public:
    virtual ~BaseEventsContainer() {}

#ifdef DEBUG
    Reaction *selectEvent(const int3 &crd);
#endif // DEBUG
    Reaction *selectEvent(double r);
    double commonRate() const;

#ifdef PRINT
    uint size() const { return _events.size(); }
#endif // PRINT

protected:
    template <class R>
    R *exchangeToLast(uint index);

    std::vector<Reaction *> _events;
};

template <class R>
R *BaseEventsContainer::exchangeToLast(uint index)
{
    assert(index < _events.size());

    Reaction *last = _events.back();
    _events.pop_back();

    if (_events.cbegin() + index != _events.cend())
    {
        _events[index] = last;
        return cast_to<R *>(last);
    }
    return nullptr;
}

}

#endif // BASE_EVENTS_CONTAINER_H
