#ifndef DUO_LATERAL_FACTORY_H
#define DUO_LATERAL_FACTORY_H

#include "lateral_factory.h"

template <class TargetLateralReaction, class MinimalCentralReaction>
class DuoLateralFactory : public LateralFactory<TargetLateralReaction, MinimalCentralReaction>
{
    SpecificSpec **_targets;

protected:
    DuoLateralFactory(LateralSpec *sidepiece, SpecificSpec **targets) :
        LateralFactory<TargetLateralReaction, MinimalCentralReaction>(sidepiece), _targets(targets) {}

    template <class NeighbourReaction>
    bool verify(LateralCreationLambda<NeighbourReaction, TargetLateralReaction, MinimalCentralReaction> &&lambda);

private:
    DuoLateralFactory(const DuoLateralFactory &) = delete;
    DuoLateralFactory(DuoLateralFactory &&) = delete;
    DuoLateralFactory &operator = (const DuoLateralFactory &) = delete;
    DuoLateralFactory &operator = (DuoLateralFactory &&) = delete;
};

// ------------------------------------------------------------------------------------------------------------------ //

template <class LR, class CR>
template <class NR>
bool DuoLateralFactory<LR, CR>::verify(LateralCreationLambda<NR, LR, CR> &&lambda)
{
    return this->highOrderVerify(std::forward<LateralCreationLambda<NR, LR, CR>>(lambda), [this]() {
        return _targets[0]->checkoutReactionWith<NR>(_targets[1]);
    });
}

#endif // DUO_LATERAL_FACTORY_H
