#ifndef UNO_LATERAL_FACTORY_H
#define UNO_LATERAL_FACTORY_H

#include "lateral_factory.h"

namespace vd
{

template <class TargetLateralReaction, class MinimalCentralReaction>
class UnoLateralFactory : public LateralFactory<TargetLateralReaction, MinimalCentralReaction>
{
    SpecificSpec *_target;

protected:
    UnoLateralFactory(LateralSpec *sidepiece, SpecificSpec *target) :
        LateralFactory<TargetLateralReaction, MinimalCentralReaction>(sidepiece), _target(target) {}

    template <class NeighbourReaction>
    bool verify(LateralCreationLambda<NeighbourReaction, TargetLateralReaction, MinimalCentralReaction> &&lambda);

private:
    UnoLateralFactory(const UnoLateralFactory &) = delete;
    UnoLateralFactory(UnoLateralFactory &&) = delete;
    UnoLateralFactory &operator = (const UnoLateralFactory &) = delete;
    UnoLateralFactory &operator = (UnoLateralFactory &&) = delete;
};

// ------------------------------------------------------------------------------------------------------------------ //

template <class LR, class CR>
template <class NR>
bool UnoLateralFactory<LR, CR>::verify(LateralCreationLambda<NR, LR, CR> &&lambda)
{
    return this->highOrderVerify(std::forward<LateralCreationLambda<NR, LR, CR>>(lambda), [this]() {
        return _target->checkoutReaction<NR>();
    });
}

}

#endif // UNO_LATERAL_FACTORY_H
