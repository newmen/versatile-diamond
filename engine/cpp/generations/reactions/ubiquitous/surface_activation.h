#ifndef SURFACE_ACTIVATION_H
#define SURFACE_ACTIVATION_H

#include "../ubiquitous.h"

class SurfaceActivation : public Ubiquitous<SURFACE_ACTIVATION>
{
    static const ushort __hToActives[];
    static const ushort __hOnAtoms[];

public:
    static void find(Atom *anchor);

    SurfaceActivation(Atom *target) : Ubiquitous(target) {}

    double rate() const { return 3600; }

    std::string name() const { return "surface activation"; }

protected:
    short toType(ushort type) const override;
    void action() override { target()->activate(); }
};

#endif // SURFACE_ACTIVATION_H
