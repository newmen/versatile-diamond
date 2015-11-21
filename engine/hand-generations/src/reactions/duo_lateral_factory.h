#ifndef DUO_LATERAL_FACTORY_H
#define DUO_LATERAL_FACTORY_H

#include "lateral_factory.h"

template <class TargetLateralReaction, class MinimalCentralReaction>
class DuoLateralFactory : public LateralFactory<TargetLateralReaction, MinimalCentralReaction>
{
protected:
    DuoLateralFactory() = default;

public:
    template <class NeighbourReaction>
    bool checkoutReaction(LateralSpec *sidepiece, SpecificSpec **targets);
    bool checkoutBaseReaction(LateralSpec *sidepiece, SpecificSpec **targets);
    bool checkoutRestReactions(LateralSpec *sidepiece, SpecificSpec **targets);

private:
    DuoLateralFactory(const DuoLateralFactory &) = delete;
    DuoLateralFactory(DuoLateralFactory &&) = delete;
    DuoLateralFactory &operator = (const DuoLateralFactory &) = delete;
    DuoLateralFactory &operator = (DuoLateralFactory &&) = delete;

    template <class NeighbourReaction>
    bool verify(SpecificSpec **targets,
                LateralCreationLambda<NeighbourReaction, TargetLateralReaction, MinimalCentralReaction> &&lambda);
};

// ------------------------------------------------------------------------------------------------------------------ //

template <class LR, class CR>
template <class NR>
bool DuoLateralFactory<LR, CR>::checkoutReaction(LateralSpec *sidepiece, SpecificSpec **targets)
{
    return verify<NR>(targets, std::move(LateralCreationLambda<NR, LR, CR>(sidepiece)));
}

template <class LR, class CR>
bool DuoLateralFactory<LR, CR>::checkoutBaseReaction(LateralSpec *sidepiece, SpecificSpec **targets)
{
    return verify<CR>(targets, std::move(LateralCreationLambda<CR, LR, CR>(sidepiece)));
}

template <class LR, class CR>
bool DuoLateralFactory<LR, CR>::checkoutRestReactions(LateralSpec *sidepiece, SpecificSpec **targets)
{
    return checkoutReaction<LR>(sidepiece, targets) || checkoutBaseReaction(sidepiece, targets);
}

template <class LR, class CR>
template <class NR>
bool DuoLateralFactory<LR, CR>::verify(SpecificSpec **targets, LateralCreationLambda<NR, LR, CR> &&lambda)
{
    return highOrderVerify(std::forward<LateralCreationLambda<NR, LR, CR>>(lambda), [targets]() {
        return targets[0]->checkoutReactionWith<NR>(targets[1]);
    });
}
\
#endif // DUO_LATERAL_FACTORY_H
