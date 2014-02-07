#include "empty_spec.h"

namespace vd
{

void EmptySpec::eraseChild(BaseSpec *child)
{
    ParentSpec::eraseChild(child);

    if (childrenNum() == 0)
    {
        remove();
    }
}

}
