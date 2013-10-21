#include "crystal.h"
#include "../atoms/atom.h"
#include "../atoms/lattice.h"
#include <omp.h>

#include <assert.h>

namespace vd
{

Crystal::Crystal(const dim3 &sizes) : _atoms(sizes, (Atom *)0)
{
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

    specifyAllAtoms();
    findAll();
}

void Crystal::insert(Atom *atom, const int3 &coords)
{
    assert(atom);
    assert(!atom->lattice());

    Atom **cell = &_atoms[coords];
    assert(!*cell);

    atom->setLattice(this, coords);
    *cell = atom;
}

void Crystal::erase(Atom *atom)
{
    assert(atom);
    assert(atom->lattice());

    Atom **cell = &_atoms[atom->lattice()->coords()];
    assert(*cell);

    atom->unsetLattice();
    *cell = 0;
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
    return atoms().reduce_plus(0, [](Atom *atom) {
        return (atom) ? 1 : 0;
    });
}

void Crystal::specifyAllAtoms()
{
    atoms().each([](Atom *atom) {
        if (atom) atom->specifyType();
    });
}

void Crystal::findAll()
{
//#pragma omp parallel
    {
        atoms().each([](Atom *atom) {
            if (atom) atom->findChildren();
        });
    }
}


}
