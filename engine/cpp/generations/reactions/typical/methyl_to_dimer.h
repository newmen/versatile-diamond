#ifndef METHYL_TO_DIMER_H
#define METHYL_TO_DIMER_H

#include "../../../reactions/mono_spec_reaction.h"
using namespace vd;

#include "../../specific_specs/dimer_crs.h"

class MethylToDimer : public MonoSpecReaction
{
public:
    static void find(DimerCRs *target);

//    using MonoSpecReaction::MonoSpecReaction;
    MethylToDimer(SpecificSpec *target) : MonoSpecReaction(target) {}

    double rate() const { return 1e7; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "methyl to dimer"; }
#endif // PRINT

protected:
    void remove() override;
};

#endif // METHYL_TO_DIMER_H
