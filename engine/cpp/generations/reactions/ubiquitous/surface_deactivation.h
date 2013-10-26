#ifndef SURFACE_DEACTIVATION_H
#define SURFACE_DEACTIVATION_H

#include "../../../reactions/ubiquitous_reaction.h"
using namespace vd;

class SurfaceDeactivation : public UbiquitousReaction
{
    static const ushort __activesOnAtoms[];
    static const ushort __activesToH[];

public:
    static void find(Atom *anchor);

    using UbiquitousReaction::UbiquitousReaction;

    double rate() const { return 2000; }

#ifdef PRINT
    std::string name() const { return "surface deactivation"; }
#endif // PRINT

protected:
    short toType(ushort type) const override;
    void action() override { target()->deactivate(); }
};

#endif // SURFACE_DEACTIVATION_H
