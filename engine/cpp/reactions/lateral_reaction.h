#ifndef LATERAL_REACTION_H
#define LATERAL_REACTION_H

#include "../species/specific_spec.h"
#include "spec_reaction.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

class LateralReaction : public SpecReaction
{
    SpecReaction *_mainReaction;
    SpecificSpec *_lateral;

public:
    void doIt() override;
    Atom *anchor() const override;
    void removeFrom(SpecificSpec *target) override;

#ifdef PRINT
    void info(std::ostream &os) override;
#endif // PRINT

protected:
    LateralReaction(SpecReaction *mainReaction, SpecificSpec *lateralSpec);
};

}

#endif // LATERAL_REACTION_H
