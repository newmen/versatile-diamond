#ifndef UBIQUITOUS_REACTION_H
#define UBIQUITOUS_REACTION_H

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
    static short delta(Atom *anchor, const ushort *typeToNum)
    {
        ushort currNum = typeToNum[anchor->type()];
        ushort prevNum;
        if (anchor->prevType() == (ushort)(-1))
        {
            prevNum = 0;
        }
        else
        {
            prevNum = typeToNum[anchor->prevType()];
        }
        return currNum - prevNum;
    }

    Atom *target() { return _target; }

    virtual short toType(ushort type) const = 0;
    virtual void action() = 0;
    virtual void remove() = 0;
};



#endif // UBIQUITOUS_REACTION_H
