#include "reactions_mixin.h"

#include <omp.h>

namespace vd
{

void ReactionsMixin::usedIn(std::shared_ptr<Reaction> &reaction)
{
    lock([this, reaction]() {
        _reactions.insert(std::pair<Reaction *, std::shared_ptr<Reaction>>(reaction.get(), reaction));
    });
}

void ReactionsMixin::unbindFrom(Reaction *reaction)
{
    lock([this, reaction]() {
        _reactions.erase(reaction);
    });
}

void ReactionsMixin::removeReactions()
{
//    for (auto &pr : _reactions)
//    {
//        pr.first->removeExcept(this);
//    }
}

}
