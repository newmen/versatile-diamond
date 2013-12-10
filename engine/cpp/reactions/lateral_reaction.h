#ifndef LATERAL_REACTION_H
#define LATERAL_REACTION_H

#include "spec_reaction.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

class LateralSpec;

class LateralReaction : public SpecReaction
{
    SpecReaction *_parent;

public:
    void doIt() override;
    Atom *anchor() const override;

    void removeFrom(SpecificSpec *spec) override;
    virtual void removeFrom(LateralSpec *spec) = 0;

#ifdef PRINT
    void info(std::ostream &os) override;
#endif // PRINT

protected:
    LateralReaction(SpecReaction *parent);
};

}

#endif // LATERAL_REACTION_H
