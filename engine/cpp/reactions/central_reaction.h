#ifndef CENTAL_REACTION_H
#define CENTAL_REACTION_H

#include <unordered_map>
#include "typical_reaction.h"
#include "single_lateral_reaction.h"

namespace vd
{

class CentralReaction : public TypicalReaction
{
public:
    void store() override;

    virtual LateralReaction *selectFrom(SingleLateralReaction **chunks, ushort num) const = 0;

protected:
    CentralReaction() = default;

    static std::unordered_map<ushort, ushort> countReactions(SingleLateralReaction **chunks, ushort num);

    SpecReaction *selectReaction(SingleLateralReaction **chunks, ushort num);

    virtual SpecReaction *lookAround() = 0;
};

}

#endif // CENTAL_REACTION_H
