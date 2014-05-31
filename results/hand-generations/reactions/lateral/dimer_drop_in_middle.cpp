#include "dimer_drop_in_middle.h"
#include "../../species/sidepiece/dimer.h"
#include "dimer_drop_at_end.h"

const char DimerDropInMiddle::__name[] = "dimer drop in middle of dimers row";
const double DimerDropInMiddle::RATE = 2.2e6 * std::exp(-1.2e3 / (1.98 * Env::T));

void DimerDropInMiddle::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    create<DimerDropAtEnd>(this, removableSpec);
}
