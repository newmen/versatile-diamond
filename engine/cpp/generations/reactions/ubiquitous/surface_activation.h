#ifndef SURFACE_ACTIVATION_H
#define SURFACE_ACTIVATION_H

#include "../../../reactions/ubiquitous_reaction.h"
using namespace vd;

class SurfaceActivation : public UbiquitousReaction
{
    static const ushort __hToActives[];
    static const ushort __hOnAtoms[];

public:
    static void find(Atom *anchor);

//    using UbiquitousReaction::UbiquitousReaction;
    SurfaceActivation(Atom *target) : UbiquitousReaction(target) {}

    double rate() const { return 3600; }

#ifdef PRINT
    std::string name() const { return "surface activation"; }
#endif // PRINT

protected:
    short toType(ushort type) const override;
    void action() override { target()->activate(); }
};

#endif // SURFACE_ACTIVATION_H
