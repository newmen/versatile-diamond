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
    while (!reactions().empty())
    {
        reactions().begin()->second->remove();
    }
}

}
