#ifndef DIMER_DROP_H
#define DIMER_DROP_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../../species/specific/dimer_cri_cli.h"
#include "../../species/sidepiece/dimer.h"
#include "../laterable_role.h"
#include "../typical.h"

class DimerDrop : public LaterableRole<Typical, DIMER_DROP, 1>, public DiamondAtomsIterator
{
    static const char __name[];

public:
    static double RATE();

    static void find(DimerCRiCLi *target);
    static void checkLaterals(Dimer *sidepiece);

    DimerDrop(SpecificSpec *target) : LaterableRole(target) {}

    void doIt() override;

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

protected:
    LateralReaction *lookAround() override;

private:
    inline void changeAtom(Atom *atom) const;
};

#endif // DIMER_DROP_H
