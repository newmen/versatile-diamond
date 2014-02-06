#include "dimer_drop_in_middle.h"
#include "../../species/sidepiece/dimer.h"
#include "dimer_drop_at_end.h"

const char *DimerDropInMiddle::name() const
{
    static const char value[] = "dimer drop in middle of dimers row";
    return value;
}

void DimerDropInMiddle::createUnconcreted(LateralSpec *removableSpec)
{
    assert(removableSpec->type() == Dimer::ID);
    create<DimerDropAtEnd>(this, removableSpec);
}
