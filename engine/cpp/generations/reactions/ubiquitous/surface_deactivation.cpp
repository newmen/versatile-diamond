#include "surface_deactivation.h"
#include "local/methyl_on_bridge_deactivation.h"

void SurfaceDeactivation::find(Atom *anchor)
{
//    findSelf<SurfaceDeactivation>(anchor);
    findChild<MethylOnBridgeDeactivation>(anchor);
}

const char *SurfaceDeactivation::name() const
{
    static const char value[] = "surface deactivation";
    return value;
}
