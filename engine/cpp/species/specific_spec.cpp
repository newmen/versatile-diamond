#include "specific_spec.h"
#include "../reactions/spec_reaction.h"

namespace vd
{

void SpecificSpec::findTypicalReactions()
{
    findAllTypicalReactions();
    setNotNew();
}

void SpecificSpec::removeReactions()
{
    eachDupReaction([](SpecReaction *reaction) {
        reaction->remove();
    });
}

}
