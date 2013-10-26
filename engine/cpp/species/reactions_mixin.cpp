#include "reactions_mixin.h"

#include <omp.h>

namespace vd
{

void ReactionsMixin::usedIn(SpecReaction *reaction)
{
    lock([this, reaction]() {
        _reactions.insert(reaction);
    });
}

void ReactionsMixin::unbindFrom(SpecReaction *reaction)
{
    lock([this, reaction]() {
        _reactions.erase(reaction);
    });
}

void ReactionsMixin::removeReactions()
{
    SpecReaction **reactionsDup;
    int n = 0;
    lock([this, &reactionsDup, &n] {
        reactionsDup = new SpecReaction *[_reactions.size()];
        for (SpecReaction *reaction : _reactions)
        {
            reactionsDup[n++] = reaction;
        }
    });

    for (int i = 0; i < n; ++i)
    {
        SpecReaction *reaction = reactionsDup[i];
        reaction->removeFrom(this);
    }

    delete [] reactionsDup;
}

}
