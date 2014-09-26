#include "ubiquitous_reaction.h"

namespace vd
{

short UbiquitousReaction::delta(const Atom *anchor, const ushort *typeToNum)
{
    return currNum(anchor, typeToNum) - prevNum(anchor, typeToNum);
}

short UbiquitousReaction::currNum(const Atom *anchor, const ushort *typeToNum)
{
    ushort currType = anchor->type();
    if (currType == NO_VALUE)
    {
        assert(anchor->prevType() != NO_VALUE);
        return -typeToNum[anchor->prevType()];
    }

    return typeToNum[currType];
}

short UbiquitousReaction::prevNum(const Atom *anchor, const ushort *typeToNum)
{
    ushort prevType = anchor->prevType();
    if (prevType != NO_VALUE && anchor->type() != NO_VALUE)
    {
        return typeToNum[prevType];
    }

    return 0;
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

void UbiquitousReaction::changeAtoms(Atom **)
{
    action();
    target()->changeType(toType());
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
