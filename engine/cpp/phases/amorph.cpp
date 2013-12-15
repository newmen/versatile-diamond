#include "amorph.h"
#include "../atoms/atom.h"

namespace vd
{

Amorph::~Amorph()
{
    for (Atom *atom : _atoms)
    {
        delete atom;
    }
}

void Amorph::insert(Atom *atom)
{
    assert(atom);
    assert(!atom->lattice());

#ifdef PARALLEL
#pragma omp critical (amorph_atoms)
#endif // PARALLEL
    _atoms.insert(atom);
}

void Amorph::erase(Atom *atom)
{
    assert(atom);
    assert(!atom->lattice());

#ifdef PARALLEL
#pragma omp critical (amorph_atoms)
#endif // PARALLEL
    _atoms.erase(atom);
}

}
