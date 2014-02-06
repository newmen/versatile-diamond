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
    uint n = 0;
    LateralReaction **reactionsDup = new LateralReaction *[reactions().size()];
    for (auto &pr : reactions())
    {
        reactionsDup[n++] = pr.second;
    }

    for (uint i = 0; i < n; ++i)
    {
        reactionsDup[i]->unconcretizeBy(this);
    }

    delete [] reactionsDup;
}

}
