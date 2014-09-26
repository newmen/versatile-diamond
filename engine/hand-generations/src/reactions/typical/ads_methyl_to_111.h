#ifndef ADS_METHYL_TO_111_H
#define ADS_METHYL_TO_111_H

#include "../../species/specific/bridge_crs.h"
#include "../typical.h"

class AdsMethylTo111 : public Typical<ADS_METHYL_TO_111>
{
    static const char __name[];

public:
    static double RATE();

    static void find(BridgeCRs *target);

    AdsMethylTo111(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

protected:
    void changeAtoms(Atom **atoms) final;
};

#endif // ADS_METHYL_TO_111_H
