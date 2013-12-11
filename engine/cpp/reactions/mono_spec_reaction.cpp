#include "mono_spec_reaction.h"
#include "../species/specific_spec.h"

#ifdef PRINT
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

Atom *MonoSpecReaction::anchor() const
{
    return _target->anchor();
}

void MonoSpecReaction::storeAs(SpecReaction *reaction)
{
    _target->usedIn(reaction);
}

bool MonoSpecReaction::removeAsFrom(SpecReaction * /* reaction */, SpecificSpec *target)
{
    assert(_target == target);

    // this can not perform because target will also be deleted (calling only from SpecificSpec::remove)
    // target->unbindFrom(reaction);

    return true;
}

#ifdef PRINT
void MonoSpecReaction::info(std::ostream &os)
{
    os << "MonoSpecReaction " << name() << " [" << this << "]: ";
    target()->anchor()->info(os);
}
#endif // PRINT

}
