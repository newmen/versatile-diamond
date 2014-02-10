#ifndef DES_METHYL_FROM_DIMER_H
#define DES_METHYL_FROM_DIMER_H

#include "../../species/specific/methyl_on_dimer_cmiu.h"
#include "../typical.h"

class DesMethylFromDimer : public Typical<DES_METHYL_FROM_DIMER>
{
    static const char __name[];

public:
    static const double RATE;

    // TODO: methyl_on_dimer(cm: u, cm: i) should be used
    static void find(MethylOnDimerCMiu *target);

    DesMethylFromDimer(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }
};

#endif // DES_METHYL_FROM_DIMER_H
