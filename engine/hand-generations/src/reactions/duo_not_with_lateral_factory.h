#ifndef DUO_NOT_WITH_LATERAL_FACTORY_H
#define DUO_NOT_WITH_LATERAL_FACTORY_H

#include "lateral_factory.h"

template <class TargetLateralReaction, class MinimalCentralReaction>
class DuoNotWithLateralFactory : public LateralFactory<TargetLateralReaction, MinimalCentralReaction>
{
    SpecificSpec **_targets;

protected:
    DuoNotWithLateralFactory(LateralSpec *sidepiece, SpecificSpec **targets) :
        LateralFactory<TargetLateralReaction, MinimalCentralReaction>(sidepiece), _targets(targets) {}

    template <class NeighbourReaction>
    bool verify(LateralCreationLambda<NeighbourReaction, TargetLateralReaction, MinimalCentralReaction> &&lambda);

private:
    DuoNotWithLateralFactory(const DuoNotWithLateralFactory &) = delete;
    DuoNotWithLateralFactory(DuoNotWithLateralFactory &&) = delete;
    DuoNotWithLateralFactory &operator = (const DuoNotWithLateralFactory &) = delete;
    DuoNotWithLateralFactory &operator = (DuoNotWithLateralFactory &&) = delete;
};

// ------------------------------------------------------------------------------------------------------------------ //

template <class LR, class CR>
template <class NR>
bool DuoNotWithLateralFactory<LR, CR>::verify(LateralCreationLambda<NR, LR, CR> &&lambda)
{
    return highOrderVerify(std::forward<LateralCreationLambda<NR, LR, CR>>(lambda), [this]() {
        return _targets[0]->checkoutReactionNotWith<NR>(_targets[1]);
    });
}
#endif // DUO_NOT_WITH_LATERAL_FACTORY_H
