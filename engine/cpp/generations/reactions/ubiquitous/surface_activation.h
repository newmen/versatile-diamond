#ifndef SURFACE_ACTIVATION_H
#define SURFACE_ACTIVATION_H

#include "data/activation_data.h"

class SurfaceActivation : public ActivationData<SURFACE_ACTIVATION>
{
public:
    static void find(Atom *anchor);

    SurfaceActivation(Atom *target) : ActivationData(target) {}

    double rate() const { return 3.198e3; }
    const std::string name() const { return "surface activation"; }
};

#endif // SURFACE_ACTIVATION_H
