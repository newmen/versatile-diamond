#ifndef REACTIONS_MIXIN_H
#define REACTIONS_MIXIN_H

#include <unordered_set>
#include "../reactions/spec_reaction.h"

#ifdef PARALLEL
#include "../tools/lockable.h"
#endif // PARALLEL

namespace vd
{

#ifdef PARALLEL
class ReactionsMixin : public Lockable
#endif // PARALLEL
#ifndef PARALLEL
class ReactionsMixin
#endif // PARALLEL
{
    std::unordered_set<SpecReaction *> _reactions;

public:
#ifndef PARALLEL
    virtual ~ReactionsMixin() {}
#endif // PARALLEL

    void usedIn(SpecReaction *reaction);
    void unbindFrom(SpecReaction *reaction);

    void removeReactions();
};

}

#endif // REACTIONS_MIXIN_H
