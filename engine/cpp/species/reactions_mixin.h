#ifndef REACTIONS_MIXIN_H
#define REACTIONS_MIXIN_H

#include <unordered_set>
#include "../tools/lockable.h"
#include "../reactions/spec_reaction.h"

namespace vd
{

class ReactionsMixin : public Lockable
{
    std::unordered_set<SpecReaction *> _reactions;

public:
    void usedIn(SpecReaction *reaction);
    void unbindFrom(SpecReaction *reaction);

    void removeReactions();
};

}

#endif // REACTIONS_MIXIN_H
