#ifndef TYPICAL_REACTION_H
#define TYPICAL_REACTION_H

#include "../../../reactions/single_reaction.h"
#include "../../../species/base_spec.h"
#include "../../../species/reactions_mixin.h"
#include "../../handbook.h"

#include <assert.h>

#include <iostream>

namespace vd
{

template <ushort RT, ushort TARGETS_NUM>
class TypicalReaction : public SingleReaction
{
    ReactionsMixin *_targets[TARGETS_NUM];

public:
    TypicalReaction(ReactionsMixin **targets);

    ullong hash() const;

    void removeExcept(ReactionsMixin *spec) override;

    void info() override;

protected:
    BaseSpec *target(uint index = 0);
};

template <ushort RT, ushort TARGETS_NUM>
TypicalReaction<RT, TARGETS_NUM>::TypicalReaction(ReactionsMixin **targets)
{
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        assert(targets[i]);
        _targets[i] = targets[i];
    }
}

template <ushort RT, ushort TARGETS_NUM>
ullong TypicalReaction<RT, TARGETS_NUM>::hash() const
{
    // TODO: can do that if targets.size > 2 and type is unsigned long long?
    ullong result = 0;
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        result = (result << 16) ^ (ullong)_targets[i];
    }
    return result;
}

template <ushort RT, ushort TARGETS_NUM>
void TypicalReaction<RT, TARGETS_NUM>::removeExcept(ReactionsMixin *spec)
{
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        if (_targets[i] == spec) continue;
        _targets[i]->unbindFrom(this);
    }

    Handbook::mc().remove<RT>(this); // must be after unbind from another species
}

template <ushort RT, ushort TARGETS_NUM>
void TypicalReaction<RT, TARGETS_NUM>::info()
{
    std::cout << "Reaction " << RT << " [" << this << "]:";
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        std::cout << " " << target(i)->atom(0)->lattice()->coords();
    }
    std::cout << std::endl;
}

template <ushort RT, ushort TARGETS_NUM>
BaseSpec *TypicalReaction<RT, TARGETS_NUM>::target(uint index)
{
    assert(index < TARGETS_NUM);
    auto spec = dynamic_cast<BaseSpec *>(_targets[index]);
    assert(spec);
    return spec;
}

}

#endif // TYPICAL_REACTION_H
