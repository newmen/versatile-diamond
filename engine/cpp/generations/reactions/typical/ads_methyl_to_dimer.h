#ifndef ADS_METHYL_TO_DIMER_H
#define ADS_METHYL_TO_DIMER_H

#include "../../species/specific/dimer_crs.h"
#include "../mono_typical.h"

class AdsMethylToDimer : public MonoTypical<ADS_METHYL_TO_DIMER>
{
public:
    static void find(DimerCRs *target);

//    using MonoTypical::MonoTypical;
    AdsMethylToDimer(SpecificSpec *target) : MonoTypical(target) {}

    double rate() const { return 1e7; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "adsorption methyl to dimer"; }
#endif // PRINT
};

#endif // ADS_METHYL_TO_DIMER_H
