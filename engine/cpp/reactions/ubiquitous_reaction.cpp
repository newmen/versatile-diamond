#include "ubiquitous_reaction.h"

namespace vd
{

short UbiquitousReaction::delta(const Atom *anchor, const ushort *typeToNum)
{
    return currNum(anchor, typeToNum) - prevNum(anchor, typeToNum);
}

ushort UbiquitousReaction::currNum(const Atom *anchor, const ushort *typeToNum)
{
    ushort currType = anchor->type();
    if (currType == NO_VALUE)
    {
        assert(anchor->prevType() != NO_VALUE);
        return 0;
    }
    else
    {
        return typeToNum[currType];
    }
}

ushort UbiquitousReaction::prevNum(const Atom *anchor, const ushort *typeToNum)
{
    ushort prevType = anchor->prevType();
    if (prevType == NO_VALUE)
    {
        assert(anchor->type() != NO_VALUE);
        return 0;
    }
    else
    {
        return typeToNum[prevType];
    }
}

void UbiquitousReaction::doIt()
{
    uint type = toType();
    assert(type != target()->type());

    action();
    target()->changeType(type);
}

#if defined(PRINT) || defined(MC_PRINT)
void UbiquitousReaction::info(IndentStream &os)
{
    os << "Reaction " << name() << " [" << this << "] ";
    os << " as <" << target()->type() << ", " << target()->prevType() << "> ";
    os << " [" << target() << "]: ";
    if (target()->lattice()) os << target()->lattice()->coords();
    else os << "amorph";
}
#endif // PRINT || MC_PRINT

}
