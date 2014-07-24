#include "diamond.h"
#include "../atoms/atom_builder.h"
#include "../finder.h"

Diamond::Diamond(const dim3 &sizes, const Behavior *behavior, int defaultSurfaceHeight) :
    DiamondCrystalProperties<Crystal>(sizes, behavior), _defaultSurfaceHeight(defaultSurfaceHeight)
{
}

Diamond::~Diamond()
{
    Finder::removeAll(atoms().data(), atoms().size());
}

void Diamond::buildAtoms()
{
    for (int i = 0; i < _defaultSurfaceHeight - 1; ++i)
    {
        makeLayer(i, 24, 4);
    }
    makeLayer(_defaultSurfaceHeight - 1, 1, 3);
}

void Diamond::bondAllAtoms()
{
    atoms().ompParallelEach([this](Atom *atom) {
        if (!atom) return;
        assert(atom->lattice());

        int z = atom->lattice()->coords().z;
        if (z > 0)
        {
            bondAround(atom);
        }

    });
}

Atom *Diamond::makeAtom(ushort type, ushort actives, const int3 &coords)
{
    AtomBuilder builder;
    Atom *atom = builder.buildCd(type, actives, this, coords);
    return atom;
}

void Diamond::findAll()
{
    Finder::initFind(atoms().data(), atoms().size());
}
