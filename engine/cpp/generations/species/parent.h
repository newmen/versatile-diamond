#ifndef PARENT_H
#define PARENT_H

#include "../../tools/typed.h"
using namespace vd;

#include "base.h"

template <class B, ushort ST, ushort USED_ATOMS_NUM = B::UsedAtomsNum>
class Parent : public Base<Typed<B, ST>, USED_ATOMS_NUM>
{
    typedef Base<Typed<B, ST>, USED_ATOMS_NUM> ParentType;

protected:
    template <class... Args>
    Parent(Args... args) : ParentType(args...) {}
};

#endif // PARENT_H
