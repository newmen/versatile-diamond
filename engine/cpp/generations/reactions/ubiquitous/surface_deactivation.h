#ifndef SURFACE_DEACTIVATION_H
#define SURFACE_DEACTIVATION_H

#include "data/deactivation_data.h"

class SurfaceDeactivation : public DeactivationData<SURFACE_DEACTIVATION>
{
    static const char __name[];

public:
    static const double RATE;

    static void find(Atom *anchor);

    SurfaceDeactivation(Atom *target) : DeactivationData(target) {}

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }
};

#endif // SURFACE_DEACTIVATION_H
