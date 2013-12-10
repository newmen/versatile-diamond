#ifndef LATERAL_H
#define LATERAL_H

#include "../../reactions/concrete_lateral_reaction.h"
using namespace vd;

#include "typical.h"

template <ushort RT, ushort LATERALS_NUM>
class Lateral : public Typical<ConcreteLateralReaction<LATERALS_NUM>, RT>
{
protected:
//    using Typical<ConcreteLateralReaction<LATERALS_NUM>, RT>::Typical;
    template <class... Args>
    Lateral(Args... args) : Typical<ConcreteLateralReaction<LATERALS_NUM>, RT>(args...) {}
};

#endif // LATERAL_H
