#ifndef DUO_WITH_LATERAL_FACTORY_H
#define DUO_WITH_LATERAL_FACTORY_H

#include "lateral_factory.h"

template <class TargetLateralReaction, class MinimalCentralReaction>
class DuoWithLateralFactory : public LateralFactory<TargetLateralReaction, MinimalCentralReaction>
{
    SpecificSpec **_targets;

protected:
    DuoWithLateralFactory(LateralSpec *sidepiece, SpecificSpec **targets) :
        LateralFactory<TargetLateralReaction, MinimalCentralReaction>(sidepiece), _targets(targets) {}

    template <class NeighbourReaction>
    bool verify(LateralCreationLambda<NeighbourReaction, TargetLateralReaction, MinimalCentralReaction> &&lambda);

private:
    DuoWithLateralFactory(const DuoWithLateralFactory &) = delete;
    DuoWithLateralFactory(DuoWithLateralFactory &&) = delete;
    DuoWithLateralFactory &operator = (const DuoWithLateralFactory &) = delete;
    DuoWithLateralFactory &operator = (DuoWithLateralFactory &&) = delete;
};

// ------------------------------------------------------------------------------------------------------------------ //

template <class LR, class CR>
template <class NR>
bool DuoWithLateralFactory<LR, CR>::verify(LateralCreationLambda<NR, LR, CR> &&lambda)
{
    return this->highOrderVerify(std::forward<LateralCreationLambda<NR, LR, CR>>(lambda), [this]() {
        return _targets[0]->checkoutReactionWith<NR>(_targets[1]);
    });
}

#endif // DUO_WITH_LATERAL_FACTORY_H
