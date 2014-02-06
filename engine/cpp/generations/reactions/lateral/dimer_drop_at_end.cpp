#include "dimer_drop_at_end.h"
#include "../typical/dimer_drop.h"
#include "../../species/sidepiece/dimer.h"

const char *DimerDropAtEnd::name() const
{
    static const char value[] = "dimer drop at end of dimers row";
    return value;
}

void DimerDropAtEnd::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    restoreParent<DimerDrop>();
}
