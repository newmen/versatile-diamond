#include "dimer_formation_at_end.h"
#include "../typical/dimer_formation.h"
#include "../../species/sidepiece/dimer.h"

void DimerFormationAtEnd::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    restoreParent<DimerFormation>();
}
