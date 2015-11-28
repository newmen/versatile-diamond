#ifndef TYPICAL_H
#define TYPICAL_H

#include "registrator.h"

template <ushort RT, ushort TARGETS_NUM = 1>
class Typical : public Registrator<ConcreteTypicalReaction<TypicalReaction, TARGETS_NUM>, RT>
{
public:
    typedef Registrator<ConcreteTypicalReaction<TypicalReaction, TARGETS_NUM>, RT> RegistratorType;

protected:
    template <class... Args> Typical(Args... args) : RegistratorType(args...) {}
};

#endif // TYPICAL_H
