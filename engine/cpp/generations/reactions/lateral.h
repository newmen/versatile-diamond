#ifndef LATERAL_H
#define LATERAL_H

#include "registrator.h"

template <ushort RT, ushort LATERALS_NUM>
class Lateral : public Registrator<ConcreteLateralReaction<LATERALS_NUM>, RT>
{
    typedef Registrator<ConcreteLateralReaction<LATERALS_NUM>, RT> ParentType;

protected:
    template <class... Args>
    Lateral(Args... args) : ParentType(args...) {}
};

#endif // LATERAL_H
