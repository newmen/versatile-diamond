#ifndef UBIQUITOUS_REACTION_H
#define UBIQUITOUS_REACTION_H

#include "../../../reaction.h"
using namespace vd;

class UbiquitousReaction : public Reaction
{
    Atom *_target;

public:
    UbiquitousReaction(Atom *target) : _target(target) {}

    void doIt();

protected:
    static short delta(Atom *anchor, const ushort *typeToNum);

    Atom *target() { return _target; }

    virtual short toType(ushort type) const = 0;
    virtual void action() = 0;
    virtual void remove() = 0;
};



#endif // UBIQUITOUS_REACTION_H
