#ifndef CONCRETE_TYPICAL_REACTION_H
#define CONCRETE_TYPICAL_REACTION_H

#include "../species/specific_spec.h"
#include "typical_reaction.h"
#include "central_reaction.h"
#include "targets.h"

namespace vd
{

template <class B, ushort TARGETS_NUM>
class ConcreteTypicalReaction : public B, public Targets<SpecificSpec, TARGETS_NUM>
{
    typedef Targets<SpecificSpec, TARGETS_NUM> TargetsType;

public:
#if defined(PRINT) || defined(MC_PRINT)
    void info(IndentStream &os);
#endif // PRINT || MC_PRINT

protected:
    ConcreteTypicalReaction(SpecificSpec *target);
    ConcreteTypicalReaction(SpecificSpec **targets);

    void eraseFromTargets(SpecReaction *reaction) override { this->erase(reaction); }
    void insertToTargets(SpecReaction *reaction) override { this->insert(reaction); }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort TARGETS_NUM>
ConcreteTypicalReaction<B, TARGETS_NUM>::ConcreteTypicalReaction(SpecificSpec *target) :
    ConcreteTypicalReaction<B, TARGETS_NUM>(&target)
{
    static_assert(TARGETS_NUM == 1, "Wrong number of typical reaction targets");
}

template <class B, ushort TARGETS_NUM>
ConcreteTypicalReaction<B, TARGETS_NUM>::ConcreteTypicalReaction(SpecificSpec **targets) : TargetsType(targets)
{
}

#if defined(PRINT) || defined(MC_PRINT)
template <class B, ushort TARGETS_NUM>
void ConcreteTypicalReaction<B, TARGETS_NUM>::info(IndentStream &os)
{
    os << "Typical reaction " << this->name() << " [" << this << "]";
    IndentStream sub = indentStream(os);
    TargetsType::info(sub);
}
#endif // PRINT || MC_PRINT

}

#endif // CONCRETE_TYPICAL_REACTION_H
