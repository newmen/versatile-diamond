#ifndef FEW_SPECS_REACTION_H
#define FEW_SPECS_REACTION_H

#include "../atoms/neighbours.h"
#include "../species/specific_spec.h"
#include "wrappable_reaction.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

template <ushort TARGETS_NUM>
class FewSpecsReaction : public WrappableReaction
{
    SpecificSpec *_targets[TARGETS_NUM];

public:
    Atom *anchor() const override;

    void storeAs(SpecReaction *reaction) override;
    bool removeAsFrom(SpecReaction *reaction, SpecificSpec *target) override;

#ifdef PRINT
    void info(std::ostream &os) override;
#endif // PRINT

    SpecificSpec *target(uint index = 0);

protected:
    FewSpecsReaction(SpecificSpec **targets);
};

template <ushort TARGETS_NUM>
FewSpecsReaction<TARGETS_NUM>::FewSpecsReaction(SpecificSpec **targets)
{
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        assert(targets[i]);
        _targets[i] = targets[i];
    }
}

template <ushort TARGETS_NUM>
Atom *FewSpecsReaction<TARGETS_NUM>::anchor() const
{
    Atom *atom = nullptr;
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        atom = _targets[i]->anchor();
        if (atom->lattice()) break;
    }
    return atom;
}

template <ushort TARGETS_NUM>
void FewSpecsReaction<TARGETS_NUM>::storeAs(SpecReaction *reaction)
{
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        _targets[i]->usedIn(reaction);
    }
}

template <ushort TARGETS_NUM>
bool FewSpecsReaction<TARGETS_NUM>::removeAsFrom(SpecReaction *reaction, SpecificSpec *target)
{
    // TODO: now works only for two parents case
    uint index = (_targets[0] == target) ? 0 : 1;
    _targets[index] = nullptr;

    SpecificSpec *another = _targets[1 - index];
    if (index == 0 || (another && another->anchor()->isVisited()))
    {
        if (another)
        {
            another->unbindFrom(reaction);
        }

        return true;
    }

    return false;
}

#ifdef PRINT
template <ushort TARGETS_NUM>
void FewSpecsReaction<TARGETS_NUM>::info(std::ostream &os)
{
    os << "Reaction " << name() << " [" << this << "]:";
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        os << " ";
        if (_targets[i])
        {
            if (_targets[i]->anchor()->lattice())
            {
                os << _targets[i]->anchor()->lattice()->coords();
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
