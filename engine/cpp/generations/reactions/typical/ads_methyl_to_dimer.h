#ifndef ADS_METHYL_TO_DIMER_H
#define ADS_METHYL_TO_DIMER_H

#include "../../../reactions/mono_spec_reaction.h"
using namespace vd;

#include "../../specific_specs/dimer_crs.h"

class AdsMethylToDimer : public MonoSpecReaction
{
public:
    static void find(DimerCRs *target);

//    using MonoSpecReaction::MonoSpecReaction;
    AdsMethylToDimer(SpecificSpec *target) : MonoSpecReaction(target) {}

    double rate() const { return 1e7; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "adsorption methyl to dimer"; }
#endif // PRINT

protected:
    void remove() override;
};

#endif // ADS_METHYL_TO_DIMER_H
