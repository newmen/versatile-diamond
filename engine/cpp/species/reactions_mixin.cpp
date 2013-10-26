#include "reactions_mixin.h"

namespace vd
{

void ReactionsMixin::usedIn(SpecReaction *reaction)
{
#ifdef PARALLEL
    lock([this, reaction]() {
#endif // PARALLEL
        _reactions.insert(reaction);
#ifdef PARALLEL
    });
#endif // PARALLEL
}

void ReactionsMixin::unbindFrom(SpecReaction *reaction)
{
#ifdef PARALLEL
    lock([this, reaction]() {
#endif // PARALLEL
        _reactions.erase(reaction);
#ifdef PARALLEL
    });
#endif // PARALLEL
}

void ReactionsMixin::removeReactions()
{
    SpecReaction **reactionsDup;
    int n = 0;

#ifdef PARALLEL
    lock([this, &reactionsDup, &n] {
#endif // PARALLEL
        reactionsDup = new SpecReaction *[_reactions.size()];
        for (SpecReaction *reaction : _reactions)
        {
            reactionsDup[n++] = reaction;
        }
#ifdef PARALLEL
    });
#endif // PARALLEL

    for (int i = 0; i < n; ++i)
    {
        SpecReaction *reaction = reactionsDup[i];
        reaction->removeFrom(this);
    }

    delete [] reactionsDup;
}

}
