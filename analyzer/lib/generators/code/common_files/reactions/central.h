#ifndef CENTRAL_H
#define CENTRAL_H

#include "registrator.h"

template <ushort RT, ushort TARGETS_NUM = 1>
class Central : public Registrator<ConcreteTypicalReaction<CentralReaction, TARGETS_NUM>, RT>
{
public:
    typedef Registrator<ConcreteTypicalReaction<CentralReaction, TARGETS_NUM>, RT> RegistratorType;

protected:
    template <class... Args> Central(Args... args) : RegistratorType(args...) {}
};

#endif // CENTRAL_H
