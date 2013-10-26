#ifndef FEW_SPECS_REACTION_H
#define FEW_SPECS_REACTION_H

#include "../tools/lockable.h"
#include "../species/base_spec.h"
#include "../species/reactions_mixin.h"
#include "spec_reaction.h"

#ifdef PRINT
#include <iostream>
#endif // PRINT

namespace vd
{

template <ushort TARGETS_NUM>
class FewSpecsReaction : public SpecReaction, public Lockable
{
    ReactionsMixin *_targets[TARGETS_NUM];

public:
    FewSpecsReaction(ReactionsMixin **targets);

    void removeFrom(ReactionsMixin *target) override;

#ifdef PRINT
    void info() override;
#endif // PRINT

protected:
    BaseSpec *target(uint index = 0);
};

template <ushort TARGETS_NUM>
FewSpecsReaction<TARGETS_NUM>::FewSpecsReaction(ReactionsMixin **targets)
{
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        assert(targets[i]);
        _targets[i] = targets[i];
    }
}

template <ushort TARGETS_NUM>
void FewSpecsReaction<TARGETS_NUM>::removeFrom(ReactionsMixin *target)
{
    uint index;
    BaseSpec *another;
    lock([this, &index, &another, target] {
        // TODO: now works only for two parents case
        index = (_targets[0] == target) ? 0 : 1;
        another = dynamic_cast<BaseSpec *>(_targets[1 - index]);

        if (index != 0 && !(another && another->atom(0)->isVisited()))
        {
            _targets[index] = 0;
        }
    });

    if (_targets[index] != 0)
    {
        if (another)
        {
            dynamic_cast<ReactionsMixin *>(another)->unbindFrom(this);
        }

        target->unbindFrom(this); // TODO: target will be removed anyway, but why unbind?
        remove();
    }
}

#ifdef PRINT
template <ushort TARGETS_NUM>
void FewSpecsReaction<TARGETS_NUM>::info()
{
    std::cout << "Reaction " << name() << " [" << this << "]:";
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        std::cout << " ";
        if (_targets[i])
        {
            std::cout << target(i)->atom(0)->lattice()->coords();
        }
        else
        {
            std::cout << "zerofied";
        }
    }
    std::cout << std::endl;
}
#endif // PRINT

template <ushort TARGETS_NUM>
BaseSpec *FewSpecsReaction<TARGETS_NUM>::target(uint index)
{
    assert(index < TARGETS_NUM);
    BaseSpec *spec = dynamic_cast<BaseSpec *>(_targets[index]);
    assert(spec);
    return spec;
}

}

#endif // FEW_SPECS_REACTION_H
