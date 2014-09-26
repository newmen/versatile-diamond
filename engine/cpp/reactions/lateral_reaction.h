#ifndef LATERAL_REACTION_H
#define LATERAL_REACTION_H

#include "../species/lateral_spec.h"
#include "spec_reaction.h"
#include "typical_reaction.h"

namespace vd
{

class LateralReaction : public SpecReaction
{
    TypicalReaction *_parent = nullptr;

protected:
    LateralReaction(TypicalReaction *parent) : _parent(parent) {}
    LateralReaction(LateralReaction *lateralParent) : _parent(lateralParent->_parent) {}

public:
    Atom *anchor() const { return _parent->anchor(); }
    void doIt() { _parent->doIt(); }

    void store() override { insertToTargets(this); }
    void remove() override { eraseFromTargets(this); }

    virtual void unconcretizeBy(LateralSpec *spec) = 0;

protected:
    void changeAtoms(Atom **) final {}

    virtual void insertToTargets(LateralReaction *reaction) = 0;
    virtual void eraseFromTargets(LateralReaction *reaction) = 0;

    void insertToParentTargets() { _parent->insertToTargets(this); }
    void eraseFromParentTargets() { _parent->eraseFromTargets(this); }

    TypicalReaction *parent() { return _parent; }
};

}

#endif // LATERAL_REACTION_H
