#include "methyl_on_bridge_deactivation.h"

const char MethylOnBridgeDeactivation::__name[] = "methyl on surface deactivation";
const double MethylOnBridgeDeactivation::RATE = Env::cH * 4.5e13 * std::exp(-0 / (1.98 * Env::T));
