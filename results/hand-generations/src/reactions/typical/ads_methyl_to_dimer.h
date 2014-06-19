#ifndef ADS_METHYL_TO_DIMER_H
#define ADS_METHYL_TO_DIMER_H

#include "../../species/specific/dimer_crs.h"
#include "../typical.h"

class AdsMethylToDimer : public Typical<ADS_METHYL_TO_DIMER>
{
    static const char __name[];

public:
    static double RATE();

    static void find(DimerCRs *target);

    AdsMethylToDimer(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }
};

#endif // ADS_METHYL_TO_DIMER_H
