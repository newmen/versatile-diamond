#ifndef CENTAL_REACTION_H
#define CENTAL_REACTION_H

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

    SpecReaction *selectReaction(SingleLateralReaction **chunks, ushort num);

    virtual SpecReaction *lookAround() = 0;
};

}

#endif // CENTAL_REACTION_H
