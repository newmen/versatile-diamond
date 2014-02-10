#ifndef EMPTY_SPEC_H
#define EMPTY_SPEC_H

#include "parent_spec.h"

namespace vd
{

class EmptySpec : public ParentSpec
{
public:
    void eraseChild(BaseSpec *child) override;

protected:
    EmptySpec() = default;
};

}

#endif // EMPTY_SPEC_H
