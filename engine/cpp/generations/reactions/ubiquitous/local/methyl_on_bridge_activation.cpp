#include "methyl_on_bridge_activation.h"

const char MethylOnBridgeActivation::__name[] = "methyl on surface activation";
const double MethylOnBridgeActivation::RATE = Env::cH * 2.8e8 * pow(Env::T, 3.5) * std::exp(-37.5e3 / (1.98 * Env::T));
