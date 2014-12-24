#ifndef SPECIFIC_SPEC_H
#define SPECIFIC_SPEC_H

#include "reactant.h"

namespace vd
{

class SpecReaction;

class SpecificSpec : public Reactant<SpecReaction>
{
public:
    void findTypicalReactions();

protected:
    SpecificSpec() = default;

    virtual void findAllTypicalReactions() = 0;

    void removeReactions();
};

}

#endif // SPECIFIC_SPEC_H
