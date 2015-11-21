#ifndef UNO_LATERAL_FACTORY_H
#define UNO_LATERAL_FACTORY_H

#include "lateral_factory.h"

template <class TargetLateralReaction, class MinimalCentralReaction>
class UnoLateralFactory : public LateralFactory<TargetLateralReaction, MinimalCentralReaction>
{
public:
    UnoLateralFactory() = default;

    template <class NeighbourReaction>
    bool checkoutReaction(LateralSpec *sidepiece, SpecificSpec *target);
    bool checkoutBaseReaction(LateralSpec *sidepiece, SpecificSpec *target);
    bool checkoutRestReactions(LateralSpec *sidepiece, SpecificSpec *target);

private:
    UnoLateralFactory(const UnoLateralFactory &) = delete;
    UnoLateralFactory(UnoLateralFactory &&) = delete;
    UnoLateralFactory &operator = (const UnoLateralFactory &) = delete;
    UnoLateralFactory &operator = (UnoLateralFactory &&) = delete;

    template <class NeighbourReaction>
    bool verify(SpecificSpec *target,
                LateralCreationLambda<NeighbourReaction, TargetLateralReaction, MinimalCentralReaction> &&lambda);
};

// ------------------------------------------------------------------------------------------------------------------ //

template <class LR, class CR>
template <class NR>
bool UnoLateralFactory<LR, CR>::checkoutReaction(LateralSpec *sidepiece, SpecificSpec *target)
{
    return verify<NR>(target, std::move(LateralCreationLambda<NR, LR, CR>(sidepiece)));
}

template <class LR, class CR>
bool UnoLateralFactory<LR, CR>::checkoutBaseReaction(LateralSpec *sidepiece, SpecificSpec *target)
{
    return verify<CR>(target, std::move(LateralCreationLambda<CR, LR, CR>(sidepiece)));
}

template <class LR, class CR>
bool UnoLateralFactory<LR, CR>::checkoutRestReactions(LateralSpec *sidepiece, SpecificSpec *target)
{
    return checkoutReaction<LR>(sidepiece, target) || checkoutBaseReaction(sidepiece, target);
}

template <class LR, class CR>
template <class NR>
bool UnoLateralFactory<LR, CR>::verify(SpecificSpec *target, LateralCreationLambda<NR, LR, CR> &&lambda)
{
    return highOrderVerify(std::forward<LateralCreationLambda<NR, LR, CR>>(lambda), [target]() {
        return target->checkoutReaction<NR>();
    });
}

#endif // UNO_LATERAL_FACTORY_H
