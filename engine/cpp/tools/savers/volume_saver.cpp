#include "volume_saver.h"

namespace vd
{

void VolumeSaver::accumulateToFrom(Accumulator *acc, Atom *atom) const
{
    atom->setVisited();
    atom->eachNeighbour([this, acc, atom](Atom *nbr) {
        acc->addBondedPair(atom, nbr);
        if (!nbr->isVisited())
        {
            accumulateToFrom(acc, nbr);
        }
    });
}

}
