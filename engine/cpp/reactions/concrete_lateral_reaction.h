#ifndef CONCRETE_LATERAL_REACTION_H
#define CONCRETE_LATERAL_REACTION_H

#include "../species/lateral_spec.h"
#include "lateral_reaction.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

template <ushort LATERALS_NUM>
class ConcreteLateralReaction : public LateralReaction
{
    SpecReaction *_parent;
    LateralSpec *_laterals[LATERALS_NUM];

public:
    void doIt() override { return _parent->doIt(); }
    Atom *anchor() const override { return _parent->anchor(); }

    void removeFrom(LateralSpec *target) override;

#ifdef PRINT
    void info(std::ostream &os) override;
#endif // PRINT

protected:
    ConcreteLateralReaction(SpecReaction *parent, LateralSpec *lateral);
    ConcreteLateralReaction(SpecReaction *parent, LateralSpec **laterals);
};

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(SpecReaction *parent, LateralSpec *lateral) :
    ConcreteLateralReaction<LATERALS_NUM>(parent, &lateral)
{
    static_assert(LATERALS_NUM == 1, "Wrong constructor for LateralReaction with one LateralSpec");
}

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(SpecReaction *parent, LateralSpec **laterals) :
    LateralReaction(parent)
{
    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        assert(laterals[i]);
        _laterals[i] = laterals[i];
        _laterals[i]->usedIn(this);
    }
}

template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::removeFrom(LateralSpec *target)
{
    bool isLateral = false;
    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        if (target == _laterals[i])
        {
            _laterals[i]->unbindFrom(this);
            isLateral = true;
            break;
        }
    }

    assert(isLateral);
    remove();
}

#ifdef PRINT
template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::info(std::ostream &os)
{
    LateralReaction::info(os);
    os << " +++>>> ";
    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        _laterals[i]->info(os);
        os << " ///";
    }
}
#endif // PRINT

}

#endif // CONCRETE_LATERAL_REACTION_H
