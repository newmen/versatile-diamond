#ifndef SPECIFIC_H
#define SPECIFIC_H

#include "../../species/specific_spec.h"
using namespace vd;

#include "base.h"

template <ushort SST, ushort USED_ATOMS_NUM, class B = SpecificSpec>
class Specific : public Base<B, SST, USED_ATOMS_NUM>
{
protected:
//    using Base<B, SST, USED_ATOMS_NUM>::Typed;
    template <class... Args>
    Specific(Args... args) : Base<B, SST, USED_ATOMS_NUM>(args...) {}

    void findChildren() override;

public:
    void store() override;
};

template <ushort SST, ushort USED_ATOMS_NUM, class B>
void Specific<SST, USED_ATOMS_NUM, B>::findChildren()
{
    if (this->isNew())
    {
        Handbook::keeper().store<SST - BaseSpecsNum>(this);
    }

    B::findChildren();
}

template <ushort SST, ushort USED_ATOMS_NUM, class B>
void Specific<SST, USED_ATOMS_NUM, B>::store()
{
    B::store();
    Base<B, SST, USED_ATOMS_NUM>::store();
}

#endif // SPECIFIC_H
