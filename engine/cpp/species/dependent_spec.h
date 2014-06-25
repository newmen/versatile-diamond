#ifndef DEPENDENT_SPEC_H
#define DEPENDENT_SPEC_H

#include "child_spec.h"

namespace vd
{

template <class B, ushort PARENTS_NUM = 1>
class DependentSpec : public ChildSpec<B, PARENTS_NUM>
{
    typedef ChildSpec<B, PARENTS_NUM> ParentType;

protected:
    template <class... Args> DependentSpec(Args... args) : ParentType(args...) {}

public:
    void store() override;
    void remove() override;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort PARENTS_NUM>
void DependentSpec<B, PARENTS_NUM>::store()
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        this->parent(i)->insertChild(this);
    }

    B::store();
}

template <class B, ushort PARENTS_NUM>
void DependentSpec<B, PARENTS_NUM>::remove()
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        this->parent(i)->eraseChild(this);
    }

    B::remove();
}

}

#endif // DEPENDENT_SPEC_H
