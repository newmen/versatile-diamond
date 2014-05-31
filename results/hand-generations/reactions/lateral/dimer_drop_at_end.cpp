#include "dimer_drop_at_end.h"
#include "../typical/dimer_drop.h"
#include "../../species/sidepiece/dimer.h"

const char DimerDropAtEnd::__name[] = "dimer drop at end of dimers row";
const double DimerDropAtEnd::RATE = 2.2e6 * std::exp(-1e3 / (1.98 * Env::T));

void DimerDropAtEnd::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    restoreParent<DimerDrop>();
}
