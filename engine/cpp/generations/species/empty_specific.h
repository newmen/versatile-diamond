#ifndef EMPTY_SPECIFIC_H
#define EMPTY_SPECIFIC_H

#include "specific_role.h"
#include "empty_dependent.h"

template <class B, ushort ST, ushort USED_PARENTS_NUM>
class EmptySpecific :
        public SpecificRole<EmptyDependent<SpecClassBuilder<B, SpecificSpec>, ST, USED_PARENTS_NUM>>
{
    typedef SpecificRole<EmptyDependent<SpecClassBuilder<B, SpecificSpec>, ST, USED_PARENTS_NUM>> ParentType;

protected:
    template <class... Args>
    EmptySpecific(Args... args) : ParentType(args...) {}
};

#endif // EMPTY_SPECIFIC_H
