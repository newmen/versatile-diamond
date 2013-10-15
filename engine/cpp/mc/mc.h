#ifndef MC_H
#define MC_H

#include <omp.h>
#include "events_container.h"

namespace vd
{

class MC
{
    double _totalRate = 0;

public:
    MC();
    virtual ~MC() {}

    double totalRate() const { return _totalRate; }

protected:
    template <class R>
    void add(EventsContainer<R> *ec, R *r);

    template <class R>
    void remove(EventsContainer<R> *ec, R *r);

    template <class R>
    void addUb(MultiEventsContainer<R> *ec, R *r, uint n);

    template <class R>
    void removeUb(MultiEventsContainer<R> *ec, R *r, uint n);

private:
    void updateRate(double r)
    {
#pragma omp atomic
        _totalRate += r;
    }
};

template <class R>
void MC::add(EventsContainer<R> *ec, R *r)
{
    ec->add(r);
    updateRate(r->rate());
}

template <class R>
void MC::remove(EventsContainer<R> *ec, R *r)
{
    ec->add(r);
    updateRate(r->rate());
}

template <class R>
void MC::addUb(MultiEventsContainer<R> *ec, R *r, uint n)
{
    ec->add(r, n);
    updateRate(r->rate() * n);
}

template <class R>
void MC::removeUb(MultiEventsContainer<R> *ec, R *r, uint n)
{
    ec->add(r, n);
    updateRate(-r->rate() * n);
}

}

#endif // MC_H
