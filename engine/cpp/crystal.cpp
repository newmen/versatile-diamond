#include "crystal.h"
#include "lattice.h"

#include <assert.h>

namespace vd
{

Crystal::Crystal(const dim3 &sizes) : _atoms(sizes)
{
    atoms().map([]() { return (Atom *)0; });
}

Crystal::~Crystal()
{
    atoms().each([](Atom *atom) {
        delete atom;
    });
}

void Crystal::initialize()
{
    buildAtoms();
    bondAllAtoms();

//    findAllSpecs();
}

void Crystal::findAllSpecs()
{
    atoms().each([](Atom *atom) {
        atom->findSpecs();
    });
}

void Crystal::insert(Atom *atom, const int3 &coords)
{
    assert(!atom->lattice());

    Atom **cell = &_atoms[coords];
    assert(!*cell);

    atom->setLattice(this, coords);
    *cell = atom;
}

void Crystal::erase(Atom *atom)
{
    assert(atom->lattice());

    Atom **cell = &_atoms[atom->lattice()->coords()];
    assert(*cell);

    atom->unsetLattice();
    *cell = 0;
}

void Crystal::remove(Atom *atom)
{
    erase(atom);
    delete atom;
}

void Crystal::makeLayer(uint z, uint type)
{
    const dim3 &sizes = atoms().sizes();
    for (uint y = 0; y < sizes.y; ++y)
        for (uint x = 0; x < sizes.x; ++x)
        {
            int3 coords(x, y, z);
            _atoms[coords] = makeAtom(type, coords);
        }

}

uint Crystal::countAtoms() const
{
    return atoms().reduce_plus(0, [](uint acc, Atom *atom) {
        return (atom) ? acc + 1 : acc;
    });
}

}
