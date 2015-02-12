#include "dimer_formation_at_end.h"
#include "../../species/sidepiece/dimer.h"

const char DimerFormationAtEnd::__name[] = "dimer formation at end of dimers row";

double DimerFormationAtEnd::RATE()
{
    static double value = getRate("DIMER_FORMATION_AT_END");
    return value;
}
