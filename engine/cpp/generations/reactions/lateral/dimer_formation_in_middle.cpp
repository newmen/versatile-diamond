#include "dimer_formation_in_middle.h"
#include "dimer_formation_at_end.h"
#include "../../species/sidepiece/dimer.h"
#include "dimer_formation_at_end.h"

void DimerFormationInMiddle::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    createBy<DimerFormationAtEnd>(this, removableSpec);
}
