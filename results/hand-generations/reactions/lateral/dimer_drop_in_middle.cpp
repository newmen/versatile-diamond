#include "dimer_drop_in_middle.h"
#include "../../species/sidepiece/dimer.h"
#include "dimer_drop_at_end.h"

const char DimerDropInMiddle::__name[] = "dimer drop in middle of dimers row";

double DimerDropInMiddle::RATE()
{
    static double value = getRate("DIMER_DROP_IN_MIDDLE");
    return value;
}

void DimerDropInMiddle::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    create<DimerDropAtEnd>(this, removableSpec);
}
