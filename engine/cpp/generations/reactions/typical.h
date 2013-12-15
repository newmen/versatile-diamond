#ifndef TYPICAL_H
#define TYPICAL_H

#include "registrator.h"

template <ushort RT, ushort TARGETS_NUM = 1>
class Typical : public Registrator<ConcreteTypicalReaction<TARGETS_NUM>, RT>
{
    typedef Registrator<ConcreteTypicalReaction<TARGETS_NUM>, RT> ParentType;

protected:
    template <class... Args>
    Typical(Args... args) : ParentType(args...) {}
};

#endif // TYPICAL_H
