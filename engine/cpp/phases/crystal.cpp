#include "crystal.h"
#include "../atoms/atom.h"
#include "../atoms/lattice.h"

//#include <iostream>

namespace vd
{

Crystal::Crystal(const dim3 &sizes) : _atoms(sizes, (Atom *)nullptr)
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

    findAll();
}

void Crystal::insert(Atom *atom, int3 &&coords)
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

    atom->setLattice(this, std::move(coords));
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

void Crystal::makeLayer(uint z, uint type)
{
    const dim3 &sizes = atoms().sizes();
    for (uint y = 0; y < sizes.y; ++y)
        for (uint x = 0; x < sizes.x; ++x)
        {
            int3 coords(x, y, z);
            _atoms[coords] = makeAtom(type, std::move(coords));
        }

}

uint Crystal::countAtoms() const
{
    return atoms().ompParallelReducePlus(0, [](Atom *atom) {
        return (atom) ? 1 : 0;
    });
}

void Crystal::setUnvisited()
{
    _atoms.each([](Atom *atom) {
        if (atom) atom->setUnvisited();
    });
}

#ifndef NDEBUG
void Crystal::checkAllVisited()
{
    _atoms.each([](Atom *atom) {
        if (atom) assert(atom->isVisited());
    });
}
#endif // NDEBUG

float3 Crystal::translate(const int3 &coords) const
{
    float3 realCoords = coords * periods();
    return realCoords + seeks(coords);
}

}
