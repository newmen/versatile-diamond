#include "methyl_on_dimer_deactivation.h"

const char MethylOnDimerDeactivation::__name[] = "methyl on dimer deactivation";
const double MethylOnDimerDeactivation::RATE = Env::cH * 4.5e13 * std::exp(-0 / (1.98 * Env::T));
