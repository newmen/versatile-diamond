#ifndef MONO_SPEC_REACTION_H
#define MONO_SPEC_REACTION_H

#include "../species/specific_spec.h"
#include "spec_reaction.h"

#ifdef PRINT
#include <iostream>
#endif // PRINT

namespace vd
{

class MonoSpecReaction : public SpecReaction
{
    SpecificSpec *_target;

protected:
    MonoSpecReaction(SpecificSpec *target);

public:
    Atom *anchor() const override;
    void removeFrom(SpecificSpec *target) override;

protected:
    SpecificSpec *target() { return _target; }

#ifdef PRINT
    void info(std::ostream &os);
#endif // PRINT
};

}

#endif // MONO_SPEC_REACTION_H
