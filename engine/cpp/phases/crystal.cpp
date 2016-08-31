#include "crystal.h"
#include "../atoms/atom.h"

namespace vd
{

Crystal::Crystal(const dim3 &sizes, const Behavior *behavior) :
    TemplatedCrystal(sizes, behavior)
{
}

void Crystal::initialize()
{
    buildAtoms();
    bondAllAtoms();

    findAll();
}

void Crystal::changeBehavior(const Behavior *behavior)
{
    atoms().changeBehavior(behavior);
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
    assert(!atoms()[coords]);

    atom->setLattice(this, coords);
    atoms()[coords] = atom;
}

void Crystal::erase(Atom *atom)
{
    assert(atom);
    assert(atom->lattice());

    Atom **cell = &atoms()[atom->lattice()->coords()];
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
            atoms()[coords] = makeAtom(type, actives, coords);
        }
}

}
