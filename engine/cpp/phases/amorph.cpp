#include "amorph.h"

namespace vd
{

void Amorph::erase(Atom *atom)
{
    assert(atom);
    assert(!atom->lattice());

    atoms().erase(atom);
}

}
