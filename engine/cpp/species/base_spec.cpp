#include "base_spec.h"

#ifdef PRINT
#include <omp.h>
#include <iostream>
#endif // PRINT

namespace vd
{

BaseSpec *BaseSpec::checkAndFind(Atom *anchor, ushort rType, ushort sType)
{
    auto spec = anchor->specByRole(rType, sType);
    if (spec)
    {
        spec->findChildren();
    }

    return spec;
}

void BaseSpec::findChildren()
{
    findAllChildren();
    _visited = true;
}

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
    if (_children.size() == 0) return;

    BaseSpec **children = new BaseSpec *[_children.size()];
    uint n = 0;

    for (BaseSpec *child : _children)
    {
        children[n++] = child;
    }

    for (uint i = 0; i < n; ++i)
    {
        children[i]->remove();
    }

    delete [] children;
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
