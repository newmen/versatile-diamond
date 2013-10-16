#ifndef UBIQUITOUS_REACTION_H
#define UBIQUITOUS_REACTION_H

#include "../../../atom.h"
#include "../../../reaction.h"
using namespace vd;

class UbiquitousReaction : public Reaction
{
    Atom *_target;

public:
    UbiquitousReaction(Atom *target) : _target(target) {}

    void doIt()
    {
        uint type = toType(_target->type());
        assert(type != _target->type());

        action();
        _target->changeType(type);

        remove();
        _target->findChildren();
    }

protected:
    Atom *target() { return _target; }

    virtual short toType(uint type) const = 0;
    virtual void action() = 0;
    virtual void remove() = 0;
};



#endif // UBIQUITOUS_REACTION_H
