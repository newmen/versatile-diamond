#ifndef TYPICAL_REACTION_H
#define TYPICAL_REACTION_H

#include "reaction.h"
#include "../specs/base_spec.h"
#include "../specs/reactions_mixin.h"
#include "../generations/handbook.h" // TODO: need to except it

namespace vd
{

template <ushort RT, ushort TARGETS_NUM>
class TypicalReaction : public Reaction
{
    BaseSpec *_targets[TARGETS_NUM];

public:
    TypicalReaction(BaseSpec **targets);

//    void removeExcept(ReactionsMixin *rm) override;
    void remove() override;

protected:
    BaseSpec *target(uint index = 0);
};

template <ushort RT, ushort TARGETS_NUM>
TypicalReaction<RT, TARGETS_NUM>::TypicalReaction(BaseSpec **targets)
{
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        _targets[i] = targets[i];
    }
}

//template <ushort RT, ushort TARGETS_NUM>
//void ConcreteTypicalReaction<RT, TARGETS_NUM>::removeExcept(ReactionsMixin *rm)
//{
//    for (int i = 0; i < TARGETS_NUM; ++i)
//    {
//        if ((void *)_targets[i] == (void *)rm) continue; // TODO: different pointer types of comparing variables

//        auto trg = dynamic_cast<ReactionsMixin *>(_targets[i]);
//        assert(trg);
//        trg->unbindFrom(this);
//    }

//    remove();
//}

template <ushort RT, ushort TARGETS_NUM>
void TypicalReaction<RT, TARGETS_NUM>::remove()
{
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        auto trg = dynamic_cast<ReactionsMixin *>(_targets[i]);
        assert(trg);
        trg->unbindFrom(this);
    }

    Handbook::mc().remove<RT>(this);
}

template <ushort RT, ushort TARGETS_NUM>
BaseSpec *TypicalReaction<RT, TARGETS_NUM>::target(uint index)
{
    assert(index < TARGETS_NUM);
    return _targets[index];
}

}

#endif // TYPICAL_REACTION_H
