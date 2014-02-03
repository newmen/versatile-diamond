#ifndef MIGRATION_DOWN_AT_DIMER_H
#define MIGRATION_DOWN_AT_DIMER_H

#include "../../species/specific/dimer_crs.h"
#include "../../species/specific/methyl_on_bridge_cbi_cmsu.h"
#include "../typical.h"

class MigrationDownAtDimer : public Typical<MIGRATION_DOWN_AT_DIMER, 2>
{
public:
    static constexpr double RATE = 1e13 * exp(-0 / (1.98 * Env::T)); // TODO: imagine

    static void find(DimerCRs *target);
    static void find(MethylOnBridgeCBiCMsu *target);

    MigrationDownAtDimer(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    std::string name() const override { return "migration down at activated dimer from methyl on bridge"; }
};

#endif // MIGRATION_DOWN_AT_DIMER_H
