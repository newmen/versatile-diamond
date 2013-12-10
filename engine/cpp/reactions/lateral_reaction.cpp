#include "lateral_reaction.h"

namespace vd
{

LateralReaction::LateralReaction(SpecReaction *parent) : _parent(parent)
{
}

void LateralReaction::doIt()
{
    return _parent->doIt();
}

Atom *LateralReaction::anchor() const
{
    return _parent->anchor();
}

void LateralReaction::removeFrom(SpecificSpec *spec)
{
    assert(false);
    _parent->removeFrom(spec);
    remove();
}

#ifdef PRINT
void LateralReaction::info(std::ostream &os)
{
    os << "LateralReaction -> ";
    _parent->info(os);
}
#endif // PRINT

}
