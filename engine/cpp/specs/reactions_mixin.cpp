#include "reactions_mixin.h"

#include <omp.h>

namespace vd
{

ReactionsMixin::~ReactionsMixin()
{
//#pragma omp critical (remove_dependent_reactions)
//    {
//        for (auto reaction : _reactions)
//        {
//            reaction->remove();
//        }
//    }
}

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

}
