#ifndef DIMER_H
#define DIMER_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../empty/symmetric_dimer.h"
#include "original_dimer.h"

class Dimer : public Symmetric<OriginalDimer, SymmetricDimer>, public DiamondAtomsIterator
{
public:
    static void find(Atom *anchor);

    Dimer(ParentSpec **parents) : Symmetric(parents) {}

protected:
    void findAllChildren() final;
    void findAllLateralReactions() final;
};

#endif // DIMER_H
