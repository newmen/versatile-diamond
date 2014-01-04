#include "surface_deactivation.h"
#include "local/methyl_on_bridge_deactivation.h"

void SurfaceDeactivation::find(Atom *anchor)
{
//    findSelf<SurfaceDeactivation>(anchor);
    findChild<MethylOnBridgeDeactivation>(anchor);
}
