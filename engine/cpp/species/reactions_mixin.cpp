#include "reactions_mixin.h"

#include <omp.h>

namespace vd
{

void ReactionsMixin::usedIn(SingleReaction *reaction)
{
    lock([this, reaction]() {
        _reactions.insert(reaction);
    });
}

void ReactionsMixin::unbindFrom(SingleReaction *reaction)
{
    lock([this, reaction]() {
        _reactions.erase(reaction);
    });
}

void ReactionsMixin::removeReactions()
{
    SingleReaction **reactionsDup;
    int n = 0;
    lock([this, &reactionsDup, &n] {
        reactionsDup = new SingleReaction *[_reactions.size()];
        for (SingleReaction *reaction : _reactions)
        {
            reactionsDup[n++] = reaction;
        }
    });

    for (int i = 0; i < n; ++i)
    {
        SingleReaction *reaction = reactionsDup[i];
//        reaction->removeExcept(this);
        reaction->removeFrom(this);
    }

    delete [] reactionsDup;
}

}
