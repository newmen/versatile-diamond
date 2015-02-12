#ifndef DIMER_DROP_H
#define DIMER_DROP_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../../species/specific/dimer_cri_cli.h"
#include "../../species/sidepiece/dimer.h"
#include "../concretizable_role.h"
#include "../central.h"

class DimerDrop : public ConcretizableRole<Central, DIMER_DROP, 1>, public DiamondAtomsIterator
{
    static const char __name[];

public:
    static double RATE();

    static void find(DimerCRiCLi *target);
    static void checkLaterals(Dimer *sidepiece);

    DimerDrop(SpecificSpec *target) : ConcretizableRole(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

    LateralReaction *selectFrom(SingleLateralReaction **chunks, ushort num) const override;

protected:
    SpecReaction *lookAround() override;

private:
    inline void changeAtom(Atom *atom) const;
};

#endif // DIMER_DROP_H
