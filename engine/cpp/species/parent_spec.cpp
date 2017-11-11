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
    if (_visited)
    {
        _visited = false;

#if defined(PRINT) || defined(SPEC_PRINT)
        debugPrint([&](IndentStream &os) {
            os << "Set " << name() << " unvisited!";
        });
#endif // PRINT || SPEC_PRINT

        for (BaseSpec *child : _children)
        {
            child->setUnvisited();
        }
    }
}

void ParentSpec::findChildren()
{
    if (!_visited)
    {
        _visited = true;

        uint num = _children.size();
        if (num > 0)
        {
#if defined(PRINT) || defined(SPEC_PRINT)
            debugPrint([&](IndentStream &os) {
                os << "Find " << num << " children of " << name();
            });
#endif // PRINT || SPEC_PRINT

            BaseSpec **specs = new BaseSpec*[num]; // max possible size
            uint n = 0;

            for (BaseSpec *child : _children)
            {
                specs[n++] = child;
            }

            for (uint i = 0; i < n; ++i)
            {
                specs[i]->findChildren();
            }

            delete [] specs;
        }

        findAllChildren();
    }
#if defined(PRINT) || defined(SPEC_PRINT)
    else
    {
        debugPrint([&](IndentStream &os) {
            os << "Spec " << name() << " is already visited";
        });
    }
#endif // PRINT || SPEC_PRINT
}

void ParentSpec::remove()
{
    while (!_children.empty())
    {
        (*_children.begin())->remove();
    }

    BaseSpec::remove();
}

}
