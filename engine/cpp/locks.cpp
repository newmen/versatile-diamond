#include "locks.h"

namespace vd
{

Locks Locks::__locks;
Locks *Locks::instance()
{
    return &__locks;
}

Locks::Locks()
{
    omp_init_lock(&_mapLock);
}

Locks::~Locks()
{
    omp_destroy_lock(&_mapLock);
}

}
