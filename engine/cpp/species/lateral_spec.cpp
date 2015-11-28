#include "lateral_spec.h"
#include "../reactions/lateral_reaction.h"

namespace vd
{

void LateralSpec::findLateralReactions()
{
    findAllLateralReactions();
    setNotNew();
}

void LateralSpec::unconcretizeReactions()
{
    uint num = reactions().size();
    if (num == 0) return;

    uint n = 0;
    LateralReaction **reactionsDup = new LateralReaction *[num];
    for (auto &pr : reactions())
    {
        reactionsDup[n++] = pr.second;
    }

    for (uint i = 0; i < num; ++i)
    {
        reactionsDup[i]->unconcretizeBy(this);
    }

    delete [] reactionsDup;
}

}
