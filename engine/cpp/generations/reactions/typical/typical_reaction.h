#ifndef TYPICAL_REACTION_H
#define TYPICAL_REACTION_H

#include "../../../reaction.h"
#include "../../../base_spec.h"
using namespace vd;

template <ushort TARGETS_NUM>
class TypicalReaction : Reaction
{
    Atom *_targets[TARGETS_NUM];

public:
    TypicalReaction(Atom **targets);
};

template <ushort TARGETS_NUM>
TypicalReaction<TARGETS_NUM>::TypicalReaction(Atom **targets)
{
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        _targets[i] = targets[i];
    }
}

#endif // TYPICAL_REACTION_H
