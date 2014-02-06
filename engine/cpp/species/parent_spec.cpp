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

void ParentSpec::setUnvisited()
{
    _visited = false;

    for (BaseSpec *child : _children)
    {
        child->setUnvisited();
    }
}

void ParentSpec::findChildren()
{
    if (!_visited)
    {
        _visited = true;

        for (BaseSpec *child : _children)
        {
            child->findChildren();
        }

        findAllChildren();
    }
}

void ParentSpec::remove()
{
    while (!_children.empty())
    {
        (*_children.begin())->remove();
    }
}

}
