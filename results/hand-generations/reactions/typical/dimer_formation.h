#ifndef DIMER_FORMATION_H
#define DIMER_FORMATION_H

#include "../../species/specific/bridge_ctsi.h"
#include "../laterable_role.h"
#include "../typical.h"

class DimerFormation : public LaterableRole<Typical, DIMER_FORMATION, 2>
{
    static const char __name[];

public:
    static const double RATE;

    static void find(BridgeCTsi *target);
    template <class L> static void ifTargets(Atom **atoms, const L &lambda);

    DimerFormation(SpecificSpec **targets) : LaterableRole(targets) {}

    void doIt() override;

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }

protected:
    LateralReaction *lookAround() override;

private:
    inline void changeAtom(Atom *atom) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class L>
void DimerFormation::ifTargets(Atom **atoms, const L &lambda)
{
    if (atoms[0]->is(28) && atoms[1]->is(28))
    {
        SpecificSpec *neighbours[2] = {
            atoms[0]->specByRole<BridgeCTsi>(28),
            atoms[1]->specByRole<BridgeCTsi>(28)
        };

        if (neighbours[0] && neighbours[1])
        {
            assert(neighbours[0] != neighbours[1]);
            lambda(neighbours);
        }
    }
}

#endif // DIMER_FORMATION_H
