#include "surface_deactivation.h"
#include "local/methyl_on_dimer_deactivation.h"

const char SurfaceDeactivation::__name[] = "surface deactivation";

double SurfaceDeactivation::RATE()
{
    static double value = getRate("SURFACE_DEACTIVATION", Env::cH());
    return value;
}

void SurfaceDeactivation::find(Atom *anchor)
{
    findChild<MethylOnDimerDeactivation>(anchor);
}
