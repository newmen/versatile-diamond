#include "surface_deactivation.h"
#include "local/methyl_on_dimer_deactivation.h"

const char SurfaceDeactivation::__name[] = "surface deactivation";
const double SurfaceDeactivation::RATE = Env::cH * 2e13 * std::exp(-0 / (1.98 * Env::T));

void SurfaceDeactivation::find(Atom *anchor)
{
//    findSelf<SurfaceDeactivation>(anchor);
    findChild<MethylOnDimerDeactivation>(anchor);
}
