#ifndef FEW_SPECS_REACTION_H
#define FEW_SPECS_REACTION_H

#include "../tools/lockable.h"
#include "../species/specific_spec.h"
#include "spec_reaction.h"

//#ifdef PRINT
#include <iostream>
//#endif // PRINT

namespace vd
{

template <ushort TARGETS_NUM>
#ifdef PARALLEL
class FewSpecsReaction : public SpecReaction, public Lockable
#endif // PARALLEL
#ifndef PARALLEL
class FewSpecsReaction : public SpecReaction
#endif // PARALLEL
{
    SpecificSpec *_targets[TARGETS_NUM];

protected:
    FewSpecsReaction(SpecificSpec **targets);

public:
    void removeFrom(SpecificSpec *target) override;

#ifdef PRINT
    void info() override;
#endif // PRINT

protected:
    template <class R>
    static void addIfHasNeighbour(SpecificSpec *target, Atom *neighbour, ushort atomType, ushort specType);

    SpecificSpec *target(uint index = 0);
};

template <ushort TARGETS_NUM>
FewSpecsReaction<TARGETS_NUM>::FewSpecsReaction(SpecificSpec **targets)
{
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        assert(targets[i]);
        _targets[i] = targets[i];
        _targets[i]->usedIn(this);
    }
}

template <ushort TARGETS_NUM>
void FewSpecsReaction<TARGETS_NUM>::removeFrom(SpecificSpec *target)
{
    SpecificSpec *another;
    bool needToRemove = false;

#ifdef PARALLEL
    lock([this, &another, &needToRemove, target] {
#endif // PARALLEL
        // TODO: now works only for two parents case
        uint index = (_targets[0] == target) ? 0 : 1;
        _targets[index] = nullptr;

        another = _targets[1 - index];
        if (index == 0 || (another && another->atom(0)->isVisited()))
        {
            needToRemove = true;
        }
#ifdef PARALLEL
    });
#endif // PARALLEL

    if (needToRemove)
    {
        if (another)
        {
            another->unbindFrom(this);
        }

        remove();
    }
}

template <>
template <class R>
void FewSpecsReaction<2>::addIfHasNeighbour(SpecificSpec *target, Atom *neighbour, ushort atomType, ushort specType)
{
    if (neighbour->is(atomType))
    {
        assert(neighbour->hasRole(atomType, specType));

        SpecificSpec *targets[2] = {
            target,
            neighbour->specificSpecByRole(atomType, specType)
        };

        SpecReaction *reaction = new R(targets);
        reaction->store();
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
SpecificSpec *FewSpecsReaction<TARGETS_NUM>::target(uint index)
{
    assert(index < TARGETS_NUM);
    assert(_targets[index]);
    return _targets[index];
}

}

#endif // FEW_SPECS_REACTION_H
