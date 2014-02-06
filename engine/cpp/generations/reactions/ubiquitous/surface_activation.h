#ifndef SURFACE_ACTIVATION_H
#define SURFACE_ACTIVATION_H

#include "data/activation_data.h"

class SurfaceActivation : public ActivationData<SURFACE_ACTIVATION>
{
public:
    static constexpr double RATE = Env::cH * 5.2e13 * exp(-6.65e3 / (1.98 * Env::T));

    static void find(Atom *anchor);

    SurfaceActivation(Atom *target) : ActivationData(target) {}

    double rate() const override { return RATE; }
    const char *name() const override;
};

#endif // SURFACE_ACTIVATION_H
