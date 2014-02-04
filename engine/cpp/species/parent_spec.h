#ifndef PARENT_SPEC_H
#define PARENT_SPEC_H

#include <unordered_set>
#include "base_spec.h"

namespace vd
{

class ParentSpec : public BaseSpec
{
    std::unordered_set<BaseSpec *> _children;

public:
    void insertChild(BaseSpec *child);
    void eraseChild(BaseSpec *child);

    void findChildren() override;
    void remove() override;

protected:
    ParentSpec() = default;

    virtual void findAllChildren() = 0;
};

}

#endif // PARENT_SPEC_H
