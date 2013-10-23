#ifndef TYPICAL_REACTION_H
#define TYPICAL_REACTION_H

#include "../../../reactions/reaction.h"
#include "../../../species/base_spec.h"
#include "../../../species/reactions_mixin.h"
#include "../../handbook.h"

#include <iostream>

namespace vd
{

template <ushort RT, ushort TARGETS_NUM>
class TypicalReaction : public Reaction
{
    BaseSpec *_targets[TARGETS_NUM];

public:
    TypicalReaction(BaseSpec **targets);

    void remove() override;
//    void removeExcept(ReactionsMixin *spec) override;

    void info() override;

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
//    removeExcept(0);
}

//template <ushort RT, ushort TARGETS_NUM>
//void TypicalReaction<RT, TARGETS_NUM>::removeExcept(ReactionsMixin *spec)
//{
//    for (int i = 0; i < TARGETS_NUM; ++i)
//    {
//        if (_targets[i] == spec) continue;

//        auto trg = dynamic_cast<ReactionsMixin *>(_targets[i]);
//        assert(trg);
//        trg->unbindFrom(this);
//    }

//    Handbook::mc().remove<RT>(this);
//}

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
    return _targets[index];
}

}

#endif // TYPICAL_REACTION_H
