#ifndef NEAR_METHYL_ON_BRIDGE_H
#define NEAR_METHYL_ON_BRIDGE_H

#include "../../../phases/diamond.h"
#include "../../../phases/diamond_atoms_iterator.h"

class NearMethylOnBridge : public DiamondAtomsIterator
{
public:
    template <class S, class L>
    static void look(ushort bridgeAtomType, Atom **atoms, const L &lambda);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class S, class L>
void NearMethylOnBridge::look(ushort bridgeAtomType, Atom **atoms, const L &lambda)
{
    eachNeighbours<2>(atoms, &Diamond::cross_100, [bridgeAtomType, lambda](Atom **neighbours) {
        if (neighbours[0]->is(6) && neighbours[1]->is(6))
        {
            assert(neighbours[0]->lattice());
            assert(neighbours[0]->lattice()->crystal() == neighbours[1]->lattice()->crystal());

            auto crystal = neighbours[0]->lattice()->crystal();
            Atom *bridgeCT = crystal->atom(Diamond::front_110_at(neighbours[0], neighbours[1]));
            if (bridgeCT && bridgeCT->is(bridgeAtomType))
            {
                auto semiSpec = bridgeCT->specByRole<S>(bridgeAtomType);
                assert(semiSpec);

                Atom *methyl = semiSpec->atom(0);
                lambda(methyl);
            }
        }
    });
}

#endif // NEAR_METHYL_ON_BRIDGE_H
