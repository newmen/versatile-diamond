#ifndef ADS_METHYL_TO_111_H
#define ADS_METHYL_TO_111_H

#include "../../species/specific/bridge_crs.h"
#include "../typical.h"

class AdsMethylTo111 : public Typical<ADS_METHYL_TO_111>
{
public:
    static constexpr double RATE = Env::cCH3 * 1.2e9 * exp(-0 / (1.98 * Env::T));

    static void find(BridgeCRs *target);

    AdsMethylTo111(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // ADS_METHYL_TO_111_H
