#include "surface_activation.h"
#include "local/methyl_on_bridge_activation.h"

void SurfaceActivation::find(Atom *anchor)
{
//    findSelf<SurfaceActivation>(anchor);
    findChild<MethylOnBridgeActivation>(anchor);
}
