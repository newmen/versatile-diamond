#ifndef SURFACE_DEACTIVATION_H
#define SURFACE_DEACTIVATION_H

#include "../ubiquitous.h"

class SurfaceDeactivation : public Ubiquitous<SURFACE_DEACTIVATION>
{
    static const ushort __activesOnAtoms[];
    static const ushort __activesToH[];

public:
    static void find(Atom *anchor);

    SurfaceDeactivation(Atom *target) : Ubiquitous(target) {}

    double rate() const { return 2000; }

    std::string name() const { return "surface deactivation"; }

protected:
    short toType(ushort type) const override;
    void action() override { target()->deactivate(); }
};

#endif // SURFACE_DEACTIVATION_H
