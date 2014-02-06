#ifndef ADS_METHYL_TO_DIMER_H
#define ADS_METHYL_TO_DIMER_H

#include "../../species/specific/dimer_crs.h"
#include "../typical.h"

class AdsMethylToDimer : public Typical<ADS_METHYL_TO_DIMER>
{
public:
    static constexpr double RATE = Env::cCH3 * 1e13 * exp(-0 / (1.98 * Env::T));

    static void find(DimerCRs *target);

    AdsMethylToDimer(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // ADS_METHYL_TO_DIMER_H
