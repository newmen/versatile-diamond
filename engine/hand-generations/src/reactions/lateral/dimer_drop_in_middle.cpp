#include "dimer_drop_in_middle.h"

const char DimerDropInMiddle::__name[] = "dimer drop in middle of dimers row";

double DimerDropInMiddle::RATE()
{
    static double value = getRate("DIMER_DROP_IN_MIDDLE");
    return value;
}
