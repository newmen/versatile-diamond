#ifndef LATERAL_H
#define LATERAL_H

#include "../../reactions/concrete_lateral_reaction.h"
using namespace vd;

#include "typical.h"

template <ushort RT, ushort LATERALS_NUM>
class Lateral : public Typical<ConcreteLateralReaction<LATERALS_NUM>, RT>
{
    typedef ConcreteLateralReaction<LATERALS_NUM> LateralType;
    typedef Typical<ConcreteLateralReaction<LATERALS_NUM>, RT> ParentType;

protected:
    template <class... Args>
    Lateral(Args... args) : ParentType(args...) {}

    void remove() override;
};

template <ushort RT, ushort LATERALS_NUM>
void Lateral<RT, LATERALS_NUM>::remove()
{
    LateralType::remove();
    ParentType::remove();
}

#endif // LATERAL_H
