#ifndef WRAPPABLE_REACTION_H
#define WRAPPABLE_REACTION_H

#include "spec_reaction.h"

namespace vd
{

class WrappableReaction : public SpecReaction
{
public:
    virtual void store() override;
    virtual void storeAs(SpecReaction *reaction) = 0;

    virtual void removeFrom(SpecificSpec *target) override;
    virtual bool removeAsFrom(SpecReaction *reaction, SpecificSpec *target) = 0;
};

}

#endif // WRAPPABLE_REACTION_H
