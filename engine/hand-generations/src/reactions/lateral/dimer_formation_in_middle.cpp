#include "dimer_formation_in_middle.h"

const char DimerFormationInMiddle::__name[] = "dimer formation in middle of dimers row";

double DimerFormationInMiddle::RATE()
{
    static double value = getRate("DIMER_FORMATION_IN_MIDDLE");
    return value;
}
