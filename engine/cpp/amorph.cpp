#include "amorph.h"
#include "atom.h"

#include <assert.h>

namespace vd
{

Amorph::Amorph()
{
}

void Amorph::insert(Atom *atom)
{
    assert(atom);
    assert(!atom->lattice());
    _atoms.insert(atom);
}

void Amorph::erase(Atom *atom)
{
    assert(atom);
    assert(!atom->lattice());
    _atoms.erase(atom);
}

}
