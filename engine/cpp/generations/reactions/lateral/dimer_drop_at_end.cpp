#include "dimer_drop_at_end.h"
#include "../typical/dimer_drop.h"
#include "../../species/sidepiece/dimer.h"

void DimerDropAtEnd::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    restoreParent<DimerDrop>();
}
