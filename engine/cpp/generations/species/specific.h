#ifndef SPECIFIC_H
#define SPECIFIC_H

#include "../../species/specific_spec.h"
using namespace vd;

#include "typed.h"

template <ushort SST, ushort USED_ATOMS_NUM, class B = SpecificSpec>
class Specific : public Typed<B, SST, USED_ATOMS_NUM>
{
protected:
//    using Typed<B, SST, USED_ATOMS_NUM>::Typed;
    template <class... Args>
    Specific(Args... args) : Typed<B, SST, USED_ATOMS_NUM>(args...) {}

    void correspondFindChildren() override;
};

template <ushort SST, ushort USED_ATOMS_NUM, class B>
void Specific<SST, USED_ATOMS_NUM, B>::correspondFindChildren()
{
    Handbook::keeper().store<SST - BaseSpecNums>(this);
}

#endif // SPECIFIC_H
