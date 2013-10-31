#include "amorph.h"
#include "../atoms/atom.h"

#include <assert.h>

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
    _atoms.insert(atom);
}

void Amorph::erase(Atom *atom)
{
    assert(atom);
    assert(!atom->lattice());
    _atoms.erase(atom);
}

}
