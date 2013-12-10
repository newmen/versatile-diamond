#ifndef PARENT_SPEC_H
#define PARENT_SPEC_H

#include <unordered_set>
#include "base_spec.h"

namespace vd
{

class ParentSpec : public BaseSpec
{
    std::unordered_set<BaseSpec *> _children;
    bool _visited = false;

public:
    void setUnvisited() override { _visited = false; }
    bool isVisited() const override { return _visited; }

    Atom *anchor() override { return atom(indexes()[0]); }

    void addChild(BaseSpec *child) override;
    void removeChild(BaseSpec *child) override;

    void remove() override;

protected:
    static BaseSpec *checkAndFind(Atom *anchor, ushort rType, ushort sType);

    friend class LateralSpec;
    void setVisited() override { _visited = true; }
};

}

#endif // PARENT_SPEC_H
