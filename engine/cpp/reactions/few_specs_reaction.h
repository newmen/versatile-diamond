#ifndef FEW_SPECS_REACTION_H
#define FEW_SPECS_REACTION_H

#include "../atoms/neighbours.h"
#include "../species/specific_spec.h"
#include "spec_reaction.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

template <ushort TARGETS_NUM>
class FewSpecsReaction : public SpecReaction
{
    SpecificSpec *_targets[TARGETS_NUM];

protected:
    FewSpecsReaction(SpecificSpec **targets);

public:
    Atom *anchor() const override;
    void removeFrom(SpecificSpec *target) override;

#ifdef PRINT
    void info(std::ostream &os) override;
#endif // PRINT

protected:
    template <class R, ushort NEIGHBOURS_NUM>
    static void find(SpecificSpec *target, Neighbours<NEIGHBOURS_NUM> &nbrs,
                     ushort otherAtomType, ushort otherSpecType);

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
Atom *FewSpecsReaction<TARGETS_NUM>::anchor() const
{
    Atom *first = _targets[0]->firstLatticedAtomIfExist();
    if (first) return first;

    for (int i = 1; i < TARGETS_NUM; ++i)
    {
        Atom *atom = _targets[i]->firstLatticedAtomIfExist();
        if (atom->lattice()) return atom;
    }

    return first;
}

template <ushort TARGETS_NUM>
void FewSpecsReaction<TARGETS_NUM>::removeFrom(SpecificSpec *target)
{
    // TODO: now works only for two parents case
    uint index = (_targets[0] == target) ? 0 : 1;
    _targets[index] = nullptr;

    SpecificSpec *another = _targets[1 - index];
    if (index == 0 || (another && another->atom(0)->isVisited()))
    {
        if (another)
        {
            another->unbindFrom(this);
        }

        remove();
    }
}

template <ushort TARGETS_NUM>
template <class R, ushort NEIGHBOURS_NUM>
void FewSpecsReaction<TARGETS_NUM>::find(SpecificSpec *target, Neighbours<NEIGHBOURS_NUM> &nbrs,
                                         ushort otherAtomType, ushort otherSpecType)
{
    for (int i = 0; i < NEIGHBOURS_NUM; ++i)
    {
        if (nbrs[i] && (i == 0 || nbrs[i]->isVisited()))
        {
            addIfHasNeighbour<R>(target, nbrs[i], otherAtomType, otherSpecType);
        }
    }
}

template <>
template <class R>
void FewSpecsReaction<2>::addIfHasNeighbour(SpecificSpec *target, Atom *neighbour, ushort atomType, ushort specType)
{
    if (neighbour->is(atomType))
    {
        auto neighbourSpec = static_cast<SpecificSpec *>(neighbour->specByRole(atomType, specType));
        if (neighbourSpec)
        {
            SpecificSpec *targets[2] = {
                target,
                neighbourSpec
            };

            createBy<R>(targets);
        }
    }
}

#ifdef PRINT
template <ushort TARGETS_NUM>
void FewSpecsReaction<TARGETS_NUM>::info(std::ostream &os)
{
    os << "Reaction " << name() << " [" << this << "]:";
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        os << " ";
        if (target(i))
        {
            if (target(i)->atom(0)->lattice())
            {
                os << target(i)->atom(0)->lattice()->coords();
            }
            else
            {
                os << "amorph";
            }
        }
        else
        {
            os << "zerofied";
        }
    }
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
