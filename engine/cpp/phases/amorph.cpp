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

    _atoms.insert(atom);
}

void Amorph::erase(Atom *atom)
{
    assert(atom);
    assert(!atom->lattice());

    _atoms.erase(atom);
}

uint Amorph::countAtoms() const
{
    return _atoms.size();
}

}
