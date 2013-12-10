#ifndef REACTION_CLARIFIER_H
#define REACTION_CLARIFIER_H

#include "../species/specific_spec.h"

namespace vd
{

template <class B, class F>
class ReactionClarifier : public B
{
public:
//    using B::B;
    template <class... Args>
    ReactionClarifier(Args... args) : B(args...) {}

    void store() override;

private:
    bool findConcretes();
};

template <class B, class F>
void ReactionClarifier<B, F>::store()
{
    if (!findConcretes())
    {
        B::store();
    }
}

template <class B, class F>
bool ReactionClarifier<B, F>::findConcretes()
{
    auto lateralReaction = F::find(this);
    if (lateralReaction)
    {
        lateralReaction->store();
    }
    return lateralReaction;
}

}

#endif // REACTION_CLARIFIER_H
