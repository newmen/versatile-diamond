#include "ubiquitous_reaction.h"
#include "../generations/finder.h" // wow wow

namespace vd
{

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

    Finder::findAll(&_target, 1);
}

#ifdef PRINT
void UbiquitousReaction::info()
{
    std::cout << "Reaction " << name() << " [" << this << "]: ";
    if (target()->lattice()) std::cout << target()->lattice()->coords();
    else std::cout << "amorph";
    std::cout << std::endl;
}
#endif // PRINT

}
