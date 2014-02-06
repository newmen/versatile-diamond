#include "dimer_formation_at_end.h"
#include "../typical/dimer_formation.h"
#include "../../species/sidepiece/dimer.h"

const char *DimerFormationAtEnd::name() const
{
    static const char value[] = "dimer formation at end of dimers row";
    return value;
}

void DimerFormationAtEnd::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    restoreParent<DimerFormation>();
}
