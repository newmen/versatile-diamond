#include "mc.h"

namespace vd
{

MC::MC()
{
}

template <class R>
void MC::add(EventsContainer<R> *ec, R *r)
{
    ec->add(r);
    updateRate(r);
}

template <class R>
void MC::remove(EventsContainer<R> *ec, R *r)
{
    ec->add(r);
    updateRate(r);
}

template <class R>
void MC::addUb(MultiEventsContainer<R> *ec, R *r, uint n)
{
    ec->add(r, n);
    updateRate(r * n);
}

template <class R>
void MC::removeUb(MultiEventsContainer<R> *ec, R *r, uint n)
{
    ec->add(r, n);
    updateRate(-r * n);
}

}
