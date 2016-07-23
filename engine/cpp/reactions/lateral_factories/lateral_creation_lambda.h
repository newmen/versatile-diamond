#ifndef LATERAL_CREATION_LAMBDA_H
#define LATERAL_CREATION_LAMBDA_H

#include "../single_lateral_reaction.h"

namespace vd
{

template <class NeighbourReaction, class TargetLateralReaction, class MinimalCentralReaction>
class LateralCreationLambda
{
    LateralSpec *_sidepiece;

public:
    LateralCreationLambda(LateralSpec *sidepiece) : _sidepiece(sidepiece) {}
    LateralCreationLambda(LateralCreationLambda &&) = default;

    void operator () (NeighbourReaction *nbrReaction);

private:
    LateralCreationLambda(const LateralCreationLambda &) = delete;
    LateralCreationLambda &operator = (const LateralCreationLambda &) = delete;
    LateralCreationLambda &operator = (LateralCreationLambda &&) = delete;
};

// ------------------------------------------------------------------------------------------------------------------ //

template <class NR, class LR, class CR>
void LateralCreationLambda<NR, LR, CR>::operator () (NR *nbrReaction)
{
    assert(!_sidepiece->haveReaction(nbrReaction));
    SingleLateralReaction *chunk = new LR(nbrReaction->parent(), _sidepiece);
    nbrReaction->concretize(chunk);
}

//////////////////////////////////////////////////////////////////////////////////////

template <class TargetLateralReaction, class MinimalCentralReaction>
class LateralCreationLambda<MinimalCentralReaction, TargetLateralReaction, MinimalCentralReaction>
{
    LateralSpec *_sidepiece;

public:
    LateralCreationLambda(LateralSpec *sidepiece) : _sidepiece(sidepiece) {}
    LateralCreationLambda(LateralCreationLambda &&) = default;

    void operator () (MinimalCentralReaction *nbrReaction);

private:
    LateralCreationLambda(const LateralCreationLambda &) = delete;
    LateralCreationLambda &operator = (const LateralCreationLambda &) = delete;
    LateralCreationLambda &operator = (LateralCreationLambda &&) = delete;
};

// ------------------------------------------------------------------------------------------------------------------ //

template <class LR, class CR>
void LateralCreationLambda<CR, LR, CR>::operator () (CR *nbrReaction)
{
    SingleLateralReaction *chunk = new LR(nbrReaction, _sidepiece);
    nbrReaction->concretize(chunk);
}

}

#endif // LATERAL_CREATION_LAMBDA_H
