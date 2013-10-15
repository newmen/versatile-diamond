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

}

#endif // MC_H
