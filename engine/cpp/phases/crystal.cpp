#include "crystal.h"
#include "../atoms/atom.h"

//#include <iostream>

namespace vd
{

Crystal::Crystal(const dim3 &sizes, const Behavior *behavior) : _atoms(behavior, sizes)
{
}

Crystal::~Crystal()
{
    eachAtom([](Atom *atom) {
        delete atom;
    });
}

void Crystal::initialize()
{
    buildAtoms();
    bondAllAtoms();

    findAll();
}

void Crystal::changeBehavior(const Behavior *behavior)
{
    _atoms.changeBehavior(behavior);
}

void Crystal::insert(Atom *atom, const int3 &coords)
{
//    static int maxHeight = 0;
//    if (coords.z > maxHeight)
//    {
//        maxHeight = coords.z;
//        std::cout << maxHeight << std::endl;
//    }

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
    *cell = nullptr;
}

void Crystal::makeLayer(uint z, ushort type, ushort actives)
{
    const dim3 &sizes = atoms().sizes();
    for (uint y = 0; y < sizes.y; ++y)
        for (uint x = 0; x < sizes.x; ++x)
        {
            int3 coords(x, y, z);
            _atoms[coords] = makeAtom(type, actives, coords);
        }
}

uint Crystal::countAtoms() const
{
    int result = 0;
    eachAtom([&result](const Atom *) {
        ++result;
    });
    return result;
}

float3 Crystal::translate(const int3 &coords) const
{
    float3 realCoords = coords * periods();
    return realCoords + seeks(coords);
}

}
