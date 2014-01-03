#ifndef EMPTY_DEPENDENT_H
#define EMPTY_DEPENDENT_H

#include "overall.h"

template <class B, ushort ST, ushort USED_PARENTS_NUM>
class EmptyDependent : public Overall<DependentSpec<B, USED_PARENTS_NUM>, ST>
{
    typedef Overall<DependentSpec<B, USED_PARENTS_NUM>, ST> ParentType;

public:
    Atom *anchor() override { return this->parent(0)->anchor(); }

protected:
    template <class... Args>
    EmptyDependent(Args... args) : ParentType(args...) {}
};

#endif // EMPTY_DEPENDENT_H
