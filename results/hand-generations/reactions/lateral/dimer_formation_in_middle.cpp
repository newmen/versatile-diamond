#include "dimer_formation_in_middle.h"
#include "dimer_formation_at_end.h"
#include "../../species/sidepiece/dimer.h"
#include "dimer_formation_at_end.h"

const char DimerFormationInMiddle::__name[] = "dimer formation in middle of dimers row";
const double DimerFormationInMiddle::RATE = 8.9e11 * std::exp(-0 / (1.98 * Env::T));

void DimerFormationInMiddle::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    create<DimerFormationAtEnd>(this, removableSpec);
}
