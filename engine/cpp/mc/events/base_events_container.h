#ifndef BASE_EVENTS_CONTAINER_H
#define BASE_EVENTS_CONTAINER_H

#include <vector>
#include <unordered_map>
#include "../../reactions/reaction.h"
#include "node.h"

namespace vd
{

class BaseEventsContainer : public Node
{
protected:
    std::vector<Reaction *> _events;

public:
    virtual ~BaseEventsContainer() {}

    void sort() override {}
    Reaction *selectEvent(double r) override;

#ifdef SERIALIZE
    std::string name() const { return _events.front()->name(); }
#endif // SERIALIZE
    double oneRate() const { return _events.front()->rate(); }
    double commonRate() const override { return _events.size() * oneRate(); }

#if defined(PRINT) || defined(MC_PRINT) || defined(SERIALIZE) || !defined(NDEBUG)
    uint size() const { return _events.size(); }
#endif // PRINT || MC_PRINT || SERIALIZE || !NDEBUG

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
