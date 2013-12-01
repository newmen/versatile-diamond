#include "lockable.h"

#ifdef PARALLEL
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
#endif // PARALLEL
