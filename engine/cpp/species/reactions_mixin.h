#ifndef REACTIONS_MIXIN_H
#define REACTIONS_MIXIN_H

#include <unordered_map>
#include "../tools/lockable.h"
#include "../reactions/reaction.h"

namespace vd
{

class ReactionsMixin : public Lockable
{
    std::unordered_map<Reaction *, std::shared_ptr<Reaction>> _reactions;

public:
    void usedIn(std::shared_ptr<Reaction> &reaction);
    void unbindFrom(Reaction *reaction);

    void removeReactions();
};

}

#endif // REACTIONS_MIXIN_H
