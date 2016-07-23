#include "phase_boundary.h"
#include "../finder.h"

PhaseBoundary::~PhaseBoundary()
{
}

// TODO: need to move it method to Amorph class?
// TODO: why to allocate memory with new instead stack using?
void PhaseBoundary::clear()
{
    Atom **removingAtoms = new Atom *[atoms().size()];
    uint n = 0;
    for (Atom *atom : atoms())
    {
        removingAtoms[n++] = atom;
    }

    Finder::removeAll(removingAtoms, atoms().size());
    delete [] removingAtoms;
}
