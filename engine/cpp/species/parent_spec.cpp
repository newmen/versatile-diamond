#include "parent_spec.h"

namespace vd
{

BaseSpec *ParentSpec::checkAndFind(Atom *anchor, ushort rType, ushort sType)
{
    auto spec = anchor->specByRole<BaseSpec>(rType, sType);
    if (spec)
    {
        spec->findChildren();
    }
    return spec;
}

void ParentSpec::addChild(BaseSpec *child)
{
    _children.insert(child);
}

void ParentSpec::removeChild(BaseSpec *child)
{
    _children.erase(child);
}

void ParentSpec::remove()
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

}
