#ifndef LATERAL_REACTION_H
#define LATERAL_REACTION_H

#include "../species/lateral_spec.h"
#include "spec_reaction.h"

namespace vd
{

class CentralReaction;

class LateralReaction : public SpecReaction
{
    CentralReaction *_parent = nullptr;

protected:
    LateralReaction(CentralReaction *parent);

public:
    CentralReaction *parent() { return _parent; }

    void doIt();

    void store() override;
    void remove() override;

    virtual void unconcretizeBy(LateralSpec *spec) = 0;

protected:
    virtual void insertToTargets(LateralReaction *reaction) = 0;
    virtual void eraseFromTargets(LateralReaction *reaction) = 0;

    void insertToParentTargets();
    void eraseFromParentTargets();
};

}

#endif // LATERAL_REACTION_H
