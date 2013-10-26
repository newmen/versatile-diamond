#ifndef TYPICAL_REACTION_H
#define TYPICAL_REACTION_H

#include <omp.h>
#include "../../../reactions/single_reaction.h"
#include "../../../species/base_spec.h"
#include "../../../species/reactions_mixin.h"
#include "../../handbook.h"

#include <assert.h>

#ifdef PRINT
#include <iostream>
#endif // PRINT

namespace vd
{

template <ushort RT, ushort TARGETS_NUM>
class TypicalReaction : public SingleReaction
{
    ReactionsMixin *_targets[TARGETS_NUM];

public:
    TypicalReaction(ReactionsMixin **targets);

//    ullong hash() const;

//    void remove() override;
//    void removeExcept(ReactionsMixin *spec) override;

#ifdef PRINT
    void info() override;
#endif // PRINT

protected:
    BaseSpec *baseTarget(uint index = 0);
    void unsetTarget(uint index);
//    ReactionsMixin **anotherTargets(ReactionsMixin *target);
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

//template <ushort RT, ushort TARGETS_NUM>
//ullong TypicalReaction<RT, TARGETS_NUM>::hash() const
//{
//    // TODO: can do that if targets.size > 2 and type is unsigned long long?
//    ullong result = 0;
//    for (int i = 0; i < TARGETS_NUM; ++i)
//    {
//        result = (result << 16) ^ (ullong)_targets[i];
//    }
//    return result;
//}

//template <ushort RT, ushort TARGETS_NUM>
//void TypicalReaction<RT, TARGETS_NUM>::remove()
//{
////    for (int i = 0; i < TARGETS_NUM; ++i)
////    {
////        if (_targets[i] == spec) continue;
////        _targets[i]->unbindFrom(this);
////    }

//    Handbook::mc().remove<RT>(this); // must be after unbind from another species
//}

//template <ushort RT, ushort TARGETS_NUM>
//void TypicalReaction<RT, TARGETS_NUM>::removeExcept(ReactionsMixin *spec)
//{
//    for (int i = 0; i < TARGETS_NUM; ++i)
//    {
//        if (_targets[i] == spec) continue;
//        _targets[i]->unbindFrom(this);
//    }

//    Handbook::mc().remove<RT>(this); // must be after unbind from another species
//}

#ifdef PRINT
template <ushort RT, ushort TARGETS_NUM>
void TypicalReaction<RT, TARGETS_NUM>::info()
{
    std::cout << "Reaction " << RT << " [" << this << "]:";
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        std::cout << " ";
        if (baseTarget(i))
        {
            std::cout << baseTarget(i)->atom(0)->lattice()->coords();
        }
        else
        {
            std::cout << "zerofied";
        }
    }
    std::cout << std::endl;
}
#endif // PRINT

template <ushort RT, ushort TARGETS_NUM>
BaseSpec *TypicalReaction<RT, TARGETS_NUM>::baseTarget(uint index)
{
    assert(index < TARGETS_NUM);

    BaseSpec *spec = 0;
//    lock([this, &spec, index] {
        if (_targets[index])
        {
            spec = dynamic_cast<BaseSpec *>(_targets[index]);
            assert(spec);
        }
//    });
    return spec;
}

template <ushort RT, ushort TARGETS_NUM>
void TypicalReaction<RT, TARGETS_NUM>::unsetTarget(uint index)
{
//    lock([this, index] {
        _targets[index] = 0;
//    });
}

//template <ushort RT, ushort TARGETS_NUM>
//ReactionsMixin **TypicalReaction<RT, TARGETS_NUM>::anotherTargets(ReactionsMixin *target)
//{
//    assert(TARGETS_NUM > 1);

//    ReactionsMixin **result;
//    if (TARGETS_NUM == 2)
//    {
//        result = &_targets[(_targets[0] == target) ? 0 : 1];
//    }
//    else
//    {
//        result = new ReactionsMixin *[TARGETS_NUM - 1]; // !! must be deleted in caller !!
//        for (int i = 0, j = 0; i < TARGETS_NUM; ++i)
//        {
//            if (_targets[i] != target) result[j++] = _targets[i];
//        }
//    }
//    return result;
//}

}

#endif // TYPICAL_REACTION_H
