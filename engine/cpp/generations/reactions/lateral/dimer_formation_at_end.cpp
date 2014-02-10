#include "dimer_formation_at_end.h"
#include "../typical/dimer_formation.h"
#include "../../species/sidepiece/dimer.h"

const char DimerFormationAtEnd::__name[] = "dimer formation at end of dimers row";
const double DimerFormationAtEnd::RATE = 8.9e11 * std::exp(-0.4e3 / (1.98 * Env::T));

void DimerFormationAtEnd::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    restoreParent<DimerFormation>();
}
