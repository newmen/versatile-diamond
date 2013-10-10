#include "crystal.h"
#include "atom.h"
#include "atom_builder.h"
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

    findAllSpecs();
}

void Crystal::findAllSpecs()
{
    atoms().each([](Atom *atom) {
        atom->findSpecs();
    });
}

void Crystal::insert(Atom *atom)
{
    assert(!atom->hasLattice());

    Atom **cell = &_atoms[atom->lattice()->coords()];
    assert(*cell != 0);

    *cell = atom;
}

void Crystal::makeLayer(AtomBuilder *builder, uint z, uint type)
{
    const dim3 &sizes = atoms().sizes();
    for (uint y = 0; y < sizes.y; ++y)
        for (uint x = 0; x < sizes.x; ++x)
        {
            uint3 coords(x, y, z);
            _atoms[coords] = builder->buildCrystalC(type, this, coords);
        }
}

}
