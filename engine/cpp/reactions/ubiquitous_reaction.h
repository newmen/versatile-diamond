#ifndef CONCRETE_UBIQUITOUS_REACTION_H
#define CONCRETE_UBIQUITOUS_REACTION_H

#include "reaction.h"

namespace vd
{

class UbiquitousReaction : public Reaction
{
    Atom *_target;

public:
    UbiquitousReaction(Atom *target) : _target(target) {}

    Atom *target() { return _target; }

    Atom *anchor() const override;
    void doIt() override;

#ifdef PRINT
    void info() override;
#endif // PRINT

protected:
    static short delta(Atom *anchor, const ushort *typeToNum);

    virtual short toType(ushort type) const = 0;
    virtual void action() = 0;
};

}

#endif // CONCRETE_UBIQUITOUS_REACTION_H
