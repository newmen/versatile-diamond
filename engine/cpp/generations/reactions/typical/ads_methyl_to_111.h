#ifndef ADS_METHYL_TO_111_H
#define ADS_METHYL_TO_111_H

#include "../../species/specific/bridge_crs.h"
#include "../typical.h"

class AdsMethylTo111 : public Typical<ADS_METHYL_TO_111>
{
public:
    static void find(BridgeCRs *target);

    AdsMethylTo111(SpecificSpec *target) : Typical(target) {}

    double rate() const { return 1e-1; }
    void doIt();

    const std::string name() const override { return "adsorption methyl to 111"; }
};

#endif // ADS_METHYL_TO_111_H
