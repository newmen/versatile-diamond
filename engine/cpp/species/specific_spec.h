#ifndef SPECIFIC_SPEC_H
#define SPECIFIC_SPEC_H

#include <unordered_set>
#include "dependent_spec.h"
#include "../reactions/spec_reaction.h"

#ifdef PARALLEL
#include "../tools/lockable.h"
#endif // PARALLEL

namespace vd
{

#ifdef PARALLEL
class SpecificSpec : public DependentSpec<1>, public Lockable
#endif // PARALLEL
#ifndef PARALLEL
class SpecificSpec : public DependentSpec<1>
#endif // PARALLEL
{
    std::unordered_set<SpecReaction *> _reactions;

public:
    SpecificSpec(ushort type, BaseSpec *parent);

    void usedIn(SpecReaction *reaction);
    void unbindFrom(SpecReaction *reaction);

    void removeReactions();
};

}

#endif // SPECIFIC_SPEC_H
