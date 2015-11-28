#ifndef LATERAL_FACTORY_H
#define LATERAL_FACTORY_H

#include "../../species/specific_spec.h"
#include "../single_lateral_reaction.h"
#include "lateral_creation_lambda.h"

namespace vd
{

template <class TargetLateralReaction, class MinimalCentralReaction>
class LateralFactory
{
    LateralSpec *_sidepiece;

protected:
    LateralFactory(LateralSpec *sidepiece) : _sidepiece(sidepiece) {}

    LateralSpec *sidepiece() { return _sidepiece; }

    template <class NeighbourReaction, class CheckoutLambda>
    bool highOrderVerify(LateralCreationLambda<NeighbourReaction, TargetLateralReaction, MinimalCentralReaction> &&creationLambda,
                         const CheckoutLambda &checkoutLambda);
};

// ------------------------------------------------------------------------------------------------------------------ //

template <class LR, class CR>
template <class NR, class L>
bool LateralFactory<LR, CR>::highOrderVerify(LateralCreationLambda<NR, LR, CR> &&creationLambda, const L &checkoutLambda)
{
    NR *nbrReaction = checkoutLambda();
    if (nbrReaction)
    {
        creationLambda(nbrReaction);
        return true;
    }
    else
    {
        return false;
    }

}

}

#endif // LATERAL_FACTORY_H
