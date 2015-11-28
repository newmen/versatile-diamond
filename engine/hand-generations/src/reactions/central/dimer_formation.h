#ifndef DIMER_FORMATION_H
#define DIMER_FORMATION_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../../species/specific/bridge_ctsi.h"
#include "../../species/sidepiece/dimer.h"
#include "../concretizable_role.h"
#include "../central.h"

class DimerFormation : public ConcretizableRole<Central, DIMER_FORMATION, 2>, public DiamondAtomsIterator
{
    static const char __name[];

public:
    static double RATE();

    static void find(BridgeCTsi *target);
    static void checkLaterals(Dimer *sidepiece);

    DimerFormation(SpecificSpec **targets) : ConcretizableRole(targets) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

    LateralReaction *selectFrom(SingleLateralReaction **chunks, ushort num) const override;

protected:
    SpecReaction *lookAround() override;

private:
    inline void changeAtom(Atom *atom) const;
};

#endif // DIMER_FORMATION_H
