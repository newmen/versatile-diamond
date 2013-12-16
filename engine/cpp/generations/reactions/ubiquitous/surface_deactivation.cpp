#include "surface_deactivation.h"
#include "local/methyl_on_dimer_deactivation.h"

void SurfaceDeactivation::find(Atom *anchor)
{
//    findSelf<SurfaceDeactivation>(anchor);
    findChild<MethylOnDimerDeactivation>(anchor);
}
