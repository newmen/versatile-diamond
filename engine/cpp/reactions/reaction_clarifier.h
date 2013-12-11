#ifndef REACTION_CLARIFIER_H
#define REACTION_CLARIFIER_H

#include "../species/specific_spec.h"
#include "lateral_reaction.h"

namespace vd
{

template <class B>
class ReactionClarifier : public B
{
public:
    template <class... Args>
    ReactionClarifier(Args... args) : B(args...) {}

    void store() override;

protected:
    virtual LateralReaction *findLateral() = 0;
};

template <class B>
void ReactionClarifier<B>::store()
{
    auto lateralReaction = findLateral();
    if (lateralReaction)
    {
        lateralReaction->store();
    }
    else
    {
        B::store();
    }
}

}

#endif // REACTION_CLARIFIER_H
