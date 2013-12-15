#ifndef SPECIFIC_SPEC_H
#define SPECIFIC_SPEC_H

#include "../reactions/spec_reaction.h"
#include "reactant.h"

namespace vd
{

class SpecificSpec : public Reactant<SpecReaction>
{
public:
    void remove() override;
};

}

#endif // SPECIFIC_SPEC_H
