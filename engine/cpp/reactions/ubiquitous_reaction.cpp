#include "ubiquitous_reaction.h"

#ifdef PRINT
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

short UbiquitousReaction::delta(Atom *anchor, const ushort *typeToNum)
{
    short currNum = 0, prevNum = 0;
    ushort at = anchor->type();

    if (at == NO_VALUE)
    {
        assert (anchor->prevType() != NO_VALUE);
        currNum = -typeToNum[anchor->prevType()];
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
    if (_target->lattice())
    {
        return _target;
    }
    else
    {
        return _target->firstCrystalNeighbour() ?
                    _target->firstCrystalNeighbour() :
                    _target;
    }
}

void UbiquitousReaction::doIt()
{
    uint type = toType(target()->type());
    assert(type != target()->type());

    action();
    target()->changeType(type);
}

#ifdef PRINT
void UbiquitousReaction::info(std::ostream &os)
{
    os << "Reaction " << name() << " [" << this << "] ";
    os << " as <" << target()->type() << ", " << target()->prevType() << ">: ";
    if (target()->lattice()) os << target()->lattice()->coords();
    else os << "amorph";
}
#endif // PRINT

}
