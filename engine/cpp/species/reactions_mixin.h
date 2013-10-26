#ifndef REACTIONS_MIXIN_H
#define REACTIONS_MIXIN_H

#include <unordered_set>
#include "../tools/lockable.h"
#include "../reactions/single_reaction.h"

namespace vd
{

class ReactionsMixin : public Lockable
{
    std::unordered_set<SingleReaction *> _reactions;

public:
    void usedIn(SingleReaction *reaction);
    void unbindFrom(SingleReaction *reaction);

    void removeReactions();
//    template <class L>
//    void eachReaction(const L &lambda);
};

//template <class L>
//void ReactionsMixin::eachReaction(const L &lambda)
//{
//    lock([this, &lambda] {
//        for (SingleReaction *reaction : _reactions)
//        {
//            lambda(reaction);
//        }
//    });
//}

}

#endif // REACTIONS_MIXIN_H
