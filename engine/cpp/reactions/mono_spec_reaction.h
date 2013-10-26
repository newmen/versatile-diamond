#ifndef MONO_SPEC_REACTION_H
#define MONO_SPEC_REACTION_H

#include "../species/base_spec.h"
#include "../species/reactions_mixin.h"
#include "spec_reaction.h"

namespace vd
{

class MonoSpecReaction : public SpecReaction
{
    ReactionsMixin *_target;

public:
    void removeFrom(ReactionsMixin *target) override;

protected:
    MonoSpecReaction(ReactionsMixin *target) : _target(target) {}

    BaseSpec *target() { return dynamic_cast<BaseSpec *>(_target); }

#ifdef PRINT
    void info();
#endif // PRINT
};

}

#endif // MONO_SPEC_REACTION_H
