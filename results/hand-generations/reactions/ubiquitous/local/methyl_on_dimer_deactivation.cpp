#include "methyl_on_dimer_deactivation.h"

const char MethylOnDimerDeactivation::__name[] = "methyl on dimer deactivation";

double MethylOnDimerDeactivation::RATE()
{
    static double value = getRate("METHYL_ON_DIMER_DEACTIVATION", Env::cH());
    return value;
}
