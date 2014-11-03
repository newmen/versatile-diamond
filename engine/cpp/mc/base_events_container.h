#ifndef BASE_EVENTS_CONTAINER_H
#define BASE_EVENTS_CONTAINER_H

#include <vector>
#include <unordered_map>
#include "../reactions/reaction.h"

namespace vd
{

class BaseEventsContainer
{
protected:
    std::vector<Reaction *> _events;

public:
    virtual ~BaseEventsContainer() {}

    Reaction *selectEvent(double r);

    double oneRate() const { return _events.front()->rate(); }
    double commonRate() const { return _events.empty() ? 0.0 : oneRate() * _events.size(); }

#if defined(PRINT) || !defined(NDEBUG)
    uint size() const { return _events.size(); }
#endif // PRINT

protected:
    BaseEventsContainer() = default;

    template <class R> R *exchangeToLast(uint index);
};

//////////////////////////////////////////////////////////////////////////////////////

template <class R>
R *BaseEventsContainer::exchangeToLast(uint index)
{
    assert(index < _events.size());

    Reaction *last = _events.back();
    _events.pop_back();

    if (_events.cbegin() + index != _events.cend())
    {
        _events[index] = last;
        return static_cast<R *>(last);
    }
    return nullptr;
}

}

#endif // BASE_EVENTS_CONTAINER_H
