#include "typical_reaction.h"

namespace vd
{

void TypicalReaction::store()
{
    SpecReaction::store();
    insertToTargets(this);
}

void TypicalReaction::remove()
{
    eraseFromTargets(this);
    SpecReaction::remove();
}

}
