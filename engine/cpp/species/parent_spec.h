#ifndef PARENT_SPEC_H
#define PARENT_SPEC_H

#include <unordered_set>
#include "base_spec.h"

namespace vd
{

class ParentSpec : public BaseSpec
{
    typedef std::unordered_set<BaseSpec *> Children;

    Children _children;
    bool _visited = false;

public:
    void insertChild(BaseSpec *child);
    virtual void eraseChild(BaseSpec *child);

    void setUnvisited() override;
    void findChildren() override;
    void remove() override;

protected:
    ParentSpec() = default;

    virtual void findAllChildren() = 0;

    uint childrenNum() const { return _children.size(); }
};

}

#endif // PARENT_SPEC_H
