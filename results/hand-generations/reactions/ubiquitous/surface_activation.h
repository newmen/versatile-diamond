#ifndef SURFACE_ACTIVATION_H
#define SURFACE_ACTIVATION_H

#include "data/activation_data.h"

class SurfaceActivation : public ActivationData<SURFACE_ACTIVATION>
{
    static const char __name[];

public:
    static const double RATE;

    static void find(Atom *anchor);

    SurfaceActivation(Atom *target) : ActivationData(target) {}

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }
};

#endif // SURFACE_ACTIVATION_H
