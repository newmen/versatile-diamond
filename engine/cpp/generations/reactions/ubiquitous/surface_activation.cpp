#include "surface_activation.h"
#include "local/methyl_on_dimer_activation.h"

const char SurfaceActivation::__name[] = "surface activation";
const double SurfaceActivation::RATE = Env::cH * 5.2e13 * std::exp(-6.65e3 / (1.98 * Env::T));

void SurfaceActivation::find(Atom *anchor)
{
//    findSelf<SurfaceActivation>(anchor);
    findChild<MethylOnDimerActivation>(anchor);
}
