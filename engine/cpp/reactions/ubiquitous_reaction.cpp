#include "ubiquitous_reaction.h"
#include "../generations/finder.h" // wow wow

//#ifdef PRINT
#include <iostream>
//#endif // PRINT

namespace vd
{

short UbiquitousReaction::delta(Atom *anchor, const ushort *typeToNum)
{
    ushort currNum = 0, prevNum = 0;
    ushort at = anchor->type();

    if (at == NO_VALUE)
    {
        if (anchor->prevType() != NO_VALUE)
        {
            currNum = -typeToNum[anchor->prevType()];
        }
    }
    else
    {
        currNum = typeToNum[at];
        if (anchor->prevType() != NO_VALUE)
        {
            prevNum = typeToNum[anchor->prevType()];
        }
    }

    return currNum - prevNum;
}

Atom *UbiquitousReaction::anchor() const
{
    return _target->lattice() ? _target : _target->crystalNeighbour();
}

void UbiquitousReaction::doIt()
{
    uint type = toType(_target->type());
    assert(type != _target->type());

    action();
    _target->changeType(type);

    Finder::findAll(&_target, 1);
}

#ifdef PRINT
void UbiquitousReaction::info()
{
    std::cout << "Reaction " << name() << " [" << this << "] ";
    std::cout << " as <" << target()->type() << ", " << target()->prevType() << ">: ";
    if (target()->lattice()) std::cout << target()->lattice()->coords();
    else std::cout << "amorph";
    std::cout << std::endl;
}
#endif // PRINT

}
