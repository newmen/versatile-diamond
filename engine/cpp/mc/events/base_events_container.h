#ifndef BASE_EVENTS_CONTAINER_H
#define BASE_EVENTS_CONTAINER_H

#include <vector>
#include <unordered_map>
#include "../../reactions/reaction.h"

namespace vd
{

class BaseEventsContainer
{
protected:
    std::vector<Reaction *> _events;

public:
    virtual ~BaseEventsContainer() {}

    Reaction *selectEvent(double r);

#ifdef SERIALIZE
    std::string name() const { return _events.front()->name(); }
#endif // SERIALIZE
    double oneRate() const;
    double commonRate() const;

#if defined(PRINT) || defined(MC_PRINT) || defined(SERIALIZE) || !defined(NDEBUG)
    uint size() const { return _events.size(); }
#endif // PRINT || MC_PRINT || SERIALIZE || !NDEBUG

protected:
    BaseEventsContainer() = default;

    template <class R> R *exchangeToLast(uint index);

private:
    BaseEventsContainer(const BaseEventsContainer &) = delete;
    BaseEventsContainer(BaseEventsContainer &&) = delete;
    BaseEventsContainer &operator = (const BaseEventsContainer &) = delete;
    BaseEventsContainer &operator = (BaseEventsContainer &&) = delete;
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
