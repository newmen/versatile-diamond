#include "ubiquitous_reaction.h"

short UbiquitousReaction::delta(Atom *anchor, const ushort *typeToNum)
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

void UbiquitousReaction::doIt()
{
    uint type = toType(_target->type());
    assert(type != _target->type());

    action();
    _target->changeType(type);

    Atom *changedAtom = _target;
    remove();

    changedAtom->findChildren();
}
