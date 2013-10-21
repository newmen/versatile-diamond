#include "lockable.h"

namespace vd
{

Lockable::Lockable()
{
    omp_init_lock(&_lock);
}

Lockable::~Lockable()
{
    omp_destroy_lock(&_lock);
}

}
