#include "surface_activation.h"
#include "local/methyl_on_dimer_activation.h"

const char SurfaceActivation::__name[] = "surface activation";

double SurfaceActivation::RATE()
{
    static double value = getRate("SURFACE_ACTIVATION") * Env::cH();
    return value;
}

void SurfaceActivation::find(Atom *anchor)
{
    findChild<MethylOnDimerActivation>(anchor);
}
