#include "surface_deactivation.h"

void SurfaceDeactivation::find(Atom *anchor)
{
    findSelf<SurfaceDeactivation>(anchor);
}
