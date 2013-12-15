#ifndef LATERAL_REACTION_H
#define LATERAL_REACTION_H

#include "../species/lateral_spec.h"
#include "spec_reaction.h"
#include "typical_reaction.h"

namespace vd
{

class LateralReaction : virtual public SpecReaction
{
    TypicalReaction *_parent = nullptr;

protected:
    LateralReaction(TypicalReaction *parent) : _parent(parent) {}
    LateralReaction(LateralReaction *lateralParent) : _parent(lateralParent->_parent) {}

public:
    Atom *anchor() const { return _parent->anchor(); }
    void doIt() { _parent->doIt(); }

    void store() override { _parent->insertToTargets(this); }
    void remove() override
    {
        _parent->eraseFromTargets(this);
        delete _parent;
    }

    virtual void unconcretizeBy(LateralSpec *spec) = 0;

protected:
    virtual void insertToTargets(LateralReaction *reaction) = 0;
    virtual void eraseFromTargets(LateralReaction *reaction) = 0;
};

}

#endif // LATERAL_REACTION_H
