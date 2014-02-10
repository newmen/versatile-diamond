#ifndef LOCK_H
#define LOCK_H

#ifdef PARALLEL
#include <omp.h>

namespace vd
{

class Lockable
{
    omp_lock_t _lock;

public:
    virtual ~Lockable();

protected:
    Lockable();

    template <class L> void lock(const L &lambda);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class L>
void Lockable::lock(const L &lambda)
{
    omp_set_lock(&_lock);
    lambda();
    omp_unset_lock(&_lock);
}

}
#endif // PARALLEL

#endif // LOCK_H
