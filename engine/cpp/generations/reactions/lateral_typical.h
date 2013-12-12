#ifndef LATERAL_TYPICAL_H
#define LATERAL_TYPICAL_H

#include "../../reactions/concrete_lateral_reaction.h"
using namespace vd;

#include "typical.h"

template <ushort RT, ushort LATERALS_NUM>
class LateralTypical : public Typical<ConcreteLateralReaction<LATERALS_NUM>, RT>
{
    typedef ConcreteLateralReaction<LATERALS_NUM> LateralType;
    typedef Typical<ConcreteLateralReaction<LATERALS_NUM>, RT> ParentType;

protected:
    template <class... Args>
    LateralTypical(Args... args) : ParentType(args...) {}

    void remove() override;
};

template <ushort RT, ushort LATERALS_NUM>
void LateralTypical<RT, LATERALS_NUM>::remove()
{
    LateralType::remove();
    ParentType::remove();

    delete this->parent();
}

#endif // LATERAL_TYPICAL_H
