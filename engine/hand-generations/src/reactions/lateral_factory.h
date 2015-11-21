#ifndef LATERAL_FACTORY_H
#define LATERAL_FACTORY_H

#include <species/specific_spec.h>
#include <reactions/single_lateral_reaction.h>
using namespace vd;

#include "lateral_creation_lambda.h"

template <class TargetLateralReaction, class MinimalCentralReaction>
class LateralFactory
{
protected:
    LateralFactory() = default;

    template <class NeighbourReaction, class CheckoutLambda>
    bool highOrderVerify(LateralCreationLambda<NeighbourReaction, TargetLateralReaction, MinimalCentralReaction> &&creationLambda,
                         const CheckoutLambda &checkoutLambda);

private:
    LateralFactory(const LateralFactory &) = delete;
    LateralFactory(LateralFactory &&) = delete;
    LateralFactory &operator = (const LateralFactory &) = delete;
    LateralFactory &operator = (LateralFactory &&) = delete;
};

// ------------------------------------------------------------------------------------------------------------------ //

template <class LR, class CR>
template <class NR, class L>
bool LateralFactory<LR, CR>::highOrderVerify(LateralCreationLambda<NR, LR, CR> &&creationLambda, const L &checkoutLambda)
{
    auto *nbrReaction = checkoutLambda();
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

#endif // LATERAL_FACTORY_H
