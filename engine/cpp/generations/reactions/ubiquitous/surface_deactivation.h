#ifndef SURFACE_DEACTIVATION_H
#define SURFACE_DEACTIVATION_H

#include "data/deactivation_data.h"

class SurfaceDeactivation : public DeactivationData<SURFACE_DEACTIVATION>
{
public:
    static constexpr double RATE = Env::cH * 2e13 * exp(-0 / (1.98 * Env::T));

    static void find(Atom *anchor);

    SurfaceDeactivation(Atom *target) : DeactivationData(target) {}

    double rate() const override { return RATE; }
    std::string name() const override { return "surface deactivation"; }
};

#endif // SURFACE_DEACTIVATION_H
