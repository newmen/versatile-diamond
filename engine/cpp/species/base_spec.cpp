#include "base_spec.h"

#ifdef PRINT
#include <omp.h>
#include <iostream>
#endif // PRINT

namespace vd
{

void BaseSpec::addChild(BaseSpec *child)
{
    _children.insert(child);
}

void BaseSpec::removeChild(BaseSpec *child)
{
    _children.erase(child);
}

void BaseSpec::remove()
{
    for (BaseSpec *child : _children)
    {
        child->remove();
    }
}

#ifdef PRINT
void BaseSpec::wasFound()
{
#ifdef PARALLEL
#pragma omp critical (print)
#endif // PARALLEL
    {
        info();
        std::cout << " was found" << std::endl;
    }
}

void BaseSpec::wasForgotten()
{
#ifdef PARALLEL
#pragma omp critical (print)
#endif // PARALLEL
    {
        info();
        std::cout << " was forgotten" << std::endl;
    }
}
#endif // PRINT

}
