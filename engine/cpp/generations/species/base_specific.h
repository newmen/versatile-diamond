#ifndef BASE_SPECIFIC_H
#define BASE_SPECIFIC_H

#include "specific_role.h"
#include "base.h"

template <class B, ushort ST, ushort USED_ATOMS_NUM>
class BaseSpecific : public SpecificRole<Base<SpecClassBuilder<B, SpecificSpec>, ST, USED_ATOMS_NUM>>
{
    typedef SpecificRole<Base<SpecClassBuilder<B, SpecificSpec>, ST, USED_ATOMS_NUM>> ParentType;

protected:
    template <class... Args>
    BaseSpecific(Args... args) : ParentType(args...) {}
};

#endif // BASE_SPECIFIC_H
