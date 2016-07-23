#include "central_reaction.h"

namespace vd
{

std::unordered_map<ushort, ushort> CentralReaction::countReactions(SingleLateralReaction **chunks, ushort num)
{
    std::unordered_map<ushort, ushort> counter;
    for (ushort i = 0; i < num; ++i)
    {
        ++counter[chunks[i]->type()];
    }
    return counter;
}

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
