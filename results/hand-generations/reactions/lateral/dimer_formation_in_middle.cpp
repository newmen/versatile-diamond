#include "dimer_formation_in_middle.h"
#include "dimer_formation_at_end.h"
#include "../../species/sidepiece/dimer.h"
#include "dimer_formation_at_end.h"

const char DimerFormationInMiddle::__name[] = "dimer formation in middle of dimers row";

double DimerFormationInMiddle::RATE()
{
    static double value = getRate("DIMER_FORMATION_IN_MIDDLE");
    return value;
}

void DimerFormationInMiddle::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    create<DimerFormationAtEnd>(this, removableSpec);
}
