#ifndef MIGRATION_THROUGH_DIMERS_ROW_H
#define MIGRATION_THROUGH_DIMERS_ROW_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../../species/specific/methyl_on_dimer_cmsiu.h"
#include "../../species/specific/dimer_crs.h"
#include "../typical.h"

class MigrationThroughDimersRow : public Typical<MIGRATION_THROUGH_DIMERS_ROW, 2>, public DiamondAtomsIterator
{
    static const char __name[];

public:
    static double RATE();

    static void find(MethylOnDimerCMsiu *target);
    static void find(DimerCRs *target);

    MigrationThroughDimersRow(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

protected:
    void changeAtoms(Atom **atoms) final;
};

#endif // MIGRATION_THROUGH_DIMERS_ROW_H
