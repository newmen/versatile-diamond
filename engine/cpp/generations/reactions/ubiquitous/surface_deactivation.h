#ifndef SURFACE_DEACTIVATION_H
#define SURFACE_DEACTIVATION_H

#include "data/deactivation_data.h"

class SurfaceDeactivation : public DeactivationData<SURFACE_DEACTIVATION>
{
public:
    static void find(Atom *anchor);

    SurfaceDeactivation(Atom *target) : DeactivationData(target) {}

    double rate() const { return 2000; }
    std::string name() const { return "surface deactivation"; }
};

#endif // SURFACE_DEACTIVATION_H
