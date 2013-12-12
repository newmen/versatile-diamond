#include "wrappable_reaction.h"

namespace vd
{

void WrappableReaction::store()
{
    storeAs(this);
}

void WrappableReaction::removeFrom(SpecificSpec *target)
{
    if (removeAsFrom(this, target))
    {
        remove();
    }
}

void WrappableReaction::removeFromAll()
{
    removeAsFromAll(this);
}

}
