#ifndef SINGLE_LATERAL_H
#define SINGLE_LATERAL_H

#include "lateral.h"

template <ushort RT, ushort LATERALS_NUM>
class SingleLateral : public Lateral<ConcreteLateralReaction<LATERALS_NUM>, RT>
{
    typedef Lateral<ConcreteLateralReaction<LATERALS_NUM>, RT> ParentType;

protected:
    template <class... Args> SingleLateral(Args... args) : ParentType(args...) {}
};

#endif // SINGLE_LATERAL_H
