#ifndef CONCRETE_LATERAL_REACTION_H
#define CONCRETE_LATERAL_REACTION_H

#include "../species/lateral_spec.h"
#include "single_lateral_reaction.h"
#include "targets.h"

namespace vd
{

template <ushort LATERALS_NUM>
class ConcreteLateralReaction : public SingleLateralReaction, public Targets<LateralSpec, LATERALS_NUM>
{
    typedef Targets<LateralSpec, LATERALS_NUM> TargetsType;

public:
#ifdef PRINT
    void info(std::ostream &os);
#endif // PRINT

    void insertToLateralTargets(LateralReaction *reaction) final { this->insert(reaction); }
    void eraseFromLateralTargets(LateralReaction *reaction) final { this->erase(reaction); }

protected:
    ConcreteLateralReaction(CentralReaction *parent, LateralSpec *sidepiece);
    ConcreteLateralReaction(CentralReaction *parent, LateralSpec **sidepieces);

    bool haveTarget(LateralSpec *spec) const final;

    void insertToTargets(LateralReaction *reaction) final;
    void eraseFromTargets(LateralReaction *reaction) final;
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(CentralReaction *parent, LateralSpec *sidepiece) :
     ConcreteLateralReaction<LATERALS_NUM>(parent, &sidepiece)
{
    static_assert(LATERALS_NUM == 1, "Wrong number of lateral reaction sidepieces");
}

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(CentralReaction *parent, LateralSpec **sidepieces) :
     SingleLateralReaction(parent), TargetsType(sidepieces)
{
}

template <ushort LATERALS_NUM>
bool ConcreteLateralReaction<LATERALS_NUM>::haveTarget(LateralSpec *spec) const
{
    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        if (this->target(i) == spec) return true;
    }
    return false;
}

template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::insertToTargets(LateralReaction *reaction)
{
    insertToParentTargets();
    insertToLateralTargets(reaction);
}

template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::eraseFromTargets(LateralReaction *reaction)
{
    eraseFromLateralTargets(reaction);
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
