#include "methyl_on_dimer_activation.h"

const char MethylOnDimerActivation::__name[] = "methyl on dimer activation";

double MethylOnDimerActivation::RATE()
{
    static double value = getRate("METHYL_ON_DIMER_ACTIVATION") * Env::cH();
    return value;
}
