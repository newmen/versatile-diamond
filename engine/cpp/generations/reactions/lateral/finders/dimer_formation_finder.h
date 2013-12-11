#ifndef DIMER_FORMATION_FINDER_H
#define DIMER_FORMATION_FINDER_H

#include "../../../../reactions/lateral_reaction.h"
using namespace vd;

#include "../../../phases/diamond_atoms_iterator.h"

class DimerFormationFinder : public DiamondAtomsIterator
{
public:
    static LateralReaction *find(SpecReaction *unlateralizedReaction);
};

#endif // DIMER_FORMATION_FINDER_H
