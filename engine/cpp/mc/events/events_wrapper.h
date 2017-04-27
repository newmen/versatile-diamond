#ifndef EVENTS_WRAPPER_H
#define EVENTS_WRAPPER_H

#include "slice.h"

namespace vd
{

template <class C>
class EventsWrapper : public Node, public C
{
public:
    Reaction *selectEvent(double r) final { return C::selectEvent(r); }
    double commonRate() const final { return C::commonRate(); }
    void sort() final {}
    void resetRate() final {}

protected:
    EventsWrapper(Slice *parent) : Node(parent)
    {
        assert(parent);
    }

    template <class R>
    void updateParentRate(const R *event, short n)
    {
        parent()->updateRate(event->rate() * n);
    }
};

}

#endif // EVENTS_WRAPPER_H
