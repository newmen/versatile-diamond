#include "mono_spec_reaction.h"
#include "../species/specific_spec.h"

#ifdef PRINT
#include <iostream>
#endif // PRINT

namespace vd
{

MonoSpecReaction::MonoSpecReaction(SpecificSpec *target) : _target(target)
{
    _target->usedIn(this);
}

Atom *MonoSpecReaction::anchor() const
{
    return _target->firstLatticedAtomIfExist();
}

void MonoSpecReaction::removeFrom(SpecificSpec *target)
{
    assert(_target == target);

    target->unbindFrom(this);
    remove();
}

#ifdef PRINT
void MonoSpecReaction::info()
{
    std::cout << "MonoSpecReaction " << name() << " [" << this << "]: ";
    target()->atom(0)->info();
    std::cout << std::endl;
}
#endif // PRINT

}
