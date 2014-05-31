#ifndef DIAMOND_ATOMS_ITERATOR_H
#define DIAMOND_ATOMS_ITERATOR_H

#include <phases/crystal_atoms_iterator.h>
using namespace vd;

#include "diamond.h"

class DiamondAtomsIterator : public CrystalAtomsIterator<Diamond>
{
};

#endif // DIAMOND_ATOMS_ITERATOR_H
