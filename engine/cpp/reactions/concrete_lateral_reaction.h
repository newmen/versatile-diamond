#ifndef CONCRETE_LATERAL_REACTION_H
#define CONCRETE_LATERAL_REACTION_H

#include "../species/lateral_spec.h"
#include "lateral_reaction.h"
#include "targets.h"

namespace vd
{

template <ushort LATERALS_NUM>
class ConcreteLateralReaction : public LateralReaction, public Targets<LateralSpec, LATERALS_NUM>
{
    typedef Targets<LateralSpec, LATERALS_NUM> TargetsType;

public:
    Atom *anchor() const { return LateralReaction::anchor(); /* || TargetsType::anchor(); */ }

#ifdef PRINT
    void info(std::ostream &os);
#endif // PRINT

protected:
    ConcreteLateralReaction(TypicalReaction *parent, LateralSpec *sidepiece);
    ConcreteLateralReaction(TypicalReaction *parent, LateralSpec **sidepieces);
    ConcreteLateralReaction(ConcreteLateralReaction<LATERALS_NUM - 1> *lateralParent, LateralSpec *sidepiece);
    ConcreteLateralReaction(ConcreteLateralReaction<LATERALS_NUM + 1> *lateralParent, LateralSpec *sidepiece);

    void insertToTargets(LateralReaction *reaction) override;
    void eraseFromTargets(LateralReaction *reaction) override;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(TypicalReaction *parent, LateralSpec *sidepiece) :
     ConcreteLateralReaction<LATERALS_NUM>(parent, &sidepiece)
{
    static_assert(LATERALS_NUM == 1, "Wrong number of lateral reaction sidepieces");
}

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(TypicalReaction *parent, LateralSpec **sidepieces) :
     LateralReaction(parent), TargetsType(sidepieces)
{
}

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(
        ConcreteLateralReaction<LATERALS_NUM - 1> *lateralParent, LateralSpec *sidepiece) :
    LateralReaction(lateralParent), TargetsType(lateralParent, sidepiece)
{
}

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(
        ConcreteLateralReaction<LATERALS_NUM + 1> *lateralParent, LateralSpec *sidepiece) :
    LateralReaction(lateralParent), TargetsType(lateralParent, sidepiece)
{
}

template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::insertToTargets(LateralReaction *reaction)
{
    insertToParentTargets();
    this->insert(reaction);
}

template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::eraseFromTargets(LateralReaction *reaction)
{
    this->erase(reaction);
    eraseFromParentTargets();
}

#ifdef PRINT
template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::info(std::ostream &os)
{
    os << "Lateral reaction " << this->name() << " [" << this << "]:";
    TargetsType::info(os);
}
#endif // PRINT

}

#endif // CONCRETE_LATERAL_REACTION_H
