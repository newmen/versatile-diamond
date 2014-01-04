#ifndef ADS_METHYL_TO_DIMER_H
#define ADS_METHYL_TO_DIMER_H

#include "../../species/specific/dimer_crs.h"
#include "../typical.h"

class AdsMethylToDimer : public Typical<ADS_METHYL_TO_DIMER>
{
public:
    static void find(DimerCRs *target);

    AdsMethylToDimer(SpecificSpec *target) : Typical(target) {}

    double rate() const { return 1e3; }
    void doIt();

    const std::string name() const override { return "adsorption methyl to dimer"; }
};

#endif // ADS_METHYL_TO_DIMER_H
