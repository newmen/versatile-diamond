#include "wrappable_reaction.h"

namespace vd
{

void WrappableReaction::store()
{
    storeAs(this);
}

void WrappableReaction::removeFrom(SpecificSpec *target)
{
    if (removeFrom(this, target))
    {
        remove();
    }
}

}
