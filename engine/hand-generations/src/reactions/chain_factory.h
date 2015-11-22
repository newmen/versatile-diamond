#ifndef CHAIN_FACTORY_H
#define CHAIN_FACTORY_H

#include "lateral_creation_lambda.h"

template <template <class, class> class SomeLateralFactory, class LR, class CR>
class ChainFactory : public SomeLateralFactory<LR, CR>
{
public:
    template <class... Args>
    ChainFactory(Args... args) : SomeLateralFactory<LR, CR>(args...) {}

    template <class NR>
    bool checkoutReaction();
    bool checkoutBaseReaction();

    bool checkoutReactions();

    template <class R>
    bool checkoutReactions();

    template <class R1, class R2, class... RS>
    bool checkoutReactions();

private:
    ChainFactory(const ChainFactory &) = delete;
    ChainFactory(ChainFactory &&) = delete;
    ChainFactory &operator = (const ChainFactory &) = delete;
    ChainFactory &operator = (ChainFactory &&) = delete;
};

// ------------------------------------------------------------------------------------------------------------------ //

template <template <class, class> class B, class LR, class CR>
template <class NR>
bool ChainFactory<B, LR, CR>::checkoutReaction()
{
    return this->template verify<NR>(std::move(LateralCreationLambda<NR, LR, CR>(this->sidepiece())));
}

template <template <class, class> class B, class LR, class CR>
bool ChainFactory<B, LR, CR>::checkoutBaseReaction()
{
    return this->template verify<CR>(std::move(LateralCreationLambda<CR, LR, CR>(this->sidepiece())));
}

template <template <class, class> class B, class LR, class CR>
template <class R>
bool ChainFactory<B, LR, CR>::checkoutReactions()
{
    return checkoutReaction<R>() || checkoutBaseReaction();
}

template <template <class, class> class B, class LR, class CR>
template <class R1, class R2, class... RS>
bool ChainFactory<B, LR, CR>::checkoutReactions()
{
    return checkoutReaction<R1>() || checkoutReactions<R2, RS...>();
}

#endif // CHAIN_FACTORY_H
