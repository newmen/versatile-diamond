#include "reactions_mixin.h"

#include <omp.h>

namespace vd
{

void ReactionsMixin::usedIn(std::shared_ptr<SingleReaction> &reaction)
{
    lock([this, reaction]() {
        _reactions.insert(std::pair<SingleReaction *, std::shared_ptr<SingleReaction>>(reaction.get(), reaction));
    });
}

void ReactionsMixin::unbindFrom(SingleReaction *reaction)
{
    lock([this, reaction]() {
        _reactions.erase(reaction);
    });
}

// Removes reactions only from MC, but not deletes they from memory. Memory deallocation occure when base specie forgets
// specific specie with correspond reactions mixin.
void ReactionsMixin::removeReactions()
{
    for (auto &pr : _reactions)
    {
        pr.first->removeExcept(this);
    }
}

}
