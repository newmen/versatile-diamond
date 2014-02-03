#include "parent_spec.h"

namespace vd
{

void ParentSpec::insertChild(BaseSpec *child)
{
    assert(_children.find(child) == _children.cend());
    _children.insert(child);
}

void ParentSpec::eraseChild(BaseSpec *child)
{
    assert(_children.find(child) != _children.cend());
    _children.erase(child);
}

void ParentSpec::findChildren()
{
    findAllChildren();
    setVisited();
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
