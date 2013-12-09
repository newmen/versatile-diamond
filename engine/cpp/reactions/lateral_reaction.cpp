#include "lateral_reaction.h"

namespace vd
{

LateralReaction::LateralReaction(SpecReaction *mainReaction, SpecificSpec *lateralSpec) :
    _mainReaction(mainReaction), _lateral(lateralSpec)
{

    _lateral->usedIn(this);
}

void LateralReaction::doIt()
{
    _mainReaction->doIt();
}

Atom *LateralReaction::anchor() const
{
    return _mainReaction->anchor();
}

void LateralReaction::removeFrom(SpecificSpec *target)
{
    if (target == _lateral)
    {
        _lateral->unbindFrom(this);
    }
    else
    {
        assert(false);
        _mainReaction->removeFrom(target);
    }

    remove();
}

#ifdef PRINT
void LateralSpecReaction::info(std::ostream &os)
{
    os << "LateralSpecReaction -> ";
    _mainReaction->info(os);
    os << " +++>>> ";
    _lateral->info(os);
}
#endif // PRINT

}
