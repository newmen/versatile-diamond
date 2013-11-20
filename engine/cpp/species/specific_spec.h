#ifndef SPECIFIC_SPEC_H
#define SPECIFIC_SPEC_H

#include <unordered_set>
#include "dependent_spec.h"
#include "../reactions/spec_reaction.h"

namespace vd
{

class SpecificSpec : public DependentSpec<1>
{
    std::unordered_set<SpecReaction *> _reactions;
    bool _isNew = true;

protected:
    SpecificSpec(BaseSpec *parent) : DependentSpec<1>(&parent) {}

public:
    void usedIn(SpecReaction *reaction);
    void unbindFrom(SpecReaction *reaction);

    void remove();

    void findReactions();
    virtual void findAllReactions() = 0;

    void findAllChildren() override {}
};

}

#endif // SPECIFIC_SPEC_H
