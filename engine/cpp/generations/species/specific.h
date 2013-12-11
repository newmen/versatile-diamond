#ifndef SPECIFIC_H
#define SPECIFIC_H

#include "../../species/removable_reactant.h"
#include "../../species/specific_spec.h"
using namespace vd;

#include "parent.h"

template <ushort SST, ushort USED_ATOMS_NUM, class B = SpecificSpec>
class Specific : public Parent<RemovableReactant<B>, SST, USED_ATOMS_NUM>
{
    typedef RemovableReactant<B> WrappingType;
    typedef Parent<WrappingType, SST, USED_ATOMS_NUM> ParentType;

protected:
    template <class... Args>
    Specific(Args... args) : ParentType(args...) {}

public:
    void store() override;
    void findChildren() override;
};

template <ushort SST, ushort USED_ATOMS_NUM, class B>
void Specific<SST, USED_ATOMS_NUM, B>::findChildren()
{
    if (this->isNew())
    {
        Handbook::specificKeeper().store(this);
    }

    B::findChildren();
}

template <ushort SST, ushort USED_ATOMS_NUM, class B>
void Specific<SST, USED_ATOMS_NUM, B>::store()
{
    WrappingType::store();
    ParentType::store();
}

#endif // SPECIFIC_H
