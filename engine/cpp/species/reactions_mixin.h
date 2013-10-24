#ifndef REACTIONS_MIXIN_H
#define REACTIONS_MIXIN_H

#include <unordered_map>
#include "../tools/lockable.h"
#include "../reactions/single_reaction.h"

namespace vd
{

class ReactionsMixin : public Lockable
{
    std::unordered_map<SingleReaction *, std::shared_ptr<SingleReaction>> _reactions;

public:
    void usedIn(std::shared_ptr<SingleReaction> &reaction);
    void unbindFrom(SingleReaction *reaction);

    void removeReactions();
};

}

#endif // REACTIONS_MIXIN_H
