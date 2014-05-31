#include "methyl_on_dimer_activation.h"

const char MethylOnDimerActivation::__name[] = "methyl on dimer activation";
const double MethylOnDimerActivation::RATE = Env::cH * 2.8e8 * pow(Env::T, 3.5) * std::exp(-37.5e3 / (1.98 * Env::T));
