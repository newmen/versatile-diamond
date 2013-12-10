#ifndef DIMER_FORMATION_FINDER_H
#define DIMER_FORMATION_FINDER_H

#include "../../../../atoms/crystal_atoms_iterator.h"
#include "../../../../reactions/lateral_reaction.h"
using namespace vd;

class DimerFormationFinder : public CrystalAtomsIterator
{
public:
    static LateralReaction *find(SpecReaction *unlateralizedReaction);
};

#endif // DIMER_FORMATION_FINDER_H
