#include "central_reaction.h"

namespace vd
{

void CentralReaction::store()
{
    SpecReaction *reaction = lookAround();
    if (reaction == this)
    {
        TypicalReaction::store();
    }
    else
    {
        reaction->store();
    }
}

SpecReaction *CentralReaction::selectReaction(SingleLateralReaction **chunks, ushort num)
{
    if (num == 0)
    {
        return this;
    }
    else
    {
        return selectFrom(chunks, num);
    }
}

}
