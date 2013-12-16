#include "surface_activation.h"
#include "local/methyl_on_dimer_activation.h"

void SurfaceActivation::find(Atom *anchor)
{
    findChild<MethylOnDimerActivation>(anchor);
}
