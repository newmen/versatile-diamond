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
    eachAtom([this](Atom *atom) {
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

#ifdef NEYRON
void Diamond::eachAround(const Atom *atom, const std::function<void (Atom *)> &block)
{
    assert(atom->lattice());
    const int3 &coords = atom->lattice()->coords();

    cross_110(atom).each(block);
    if (coords.z % 2 == 0)
    {
        front_100(atom).each(block);
        cross_100(atom).each(block);
    }
    else
    {
        cross_100(atom).each(block);
        front_100(atom).each(block);
    }
    angles_100(atom).each(block);

    bool wasAmorph = false;
    front_110(atom).each([&wasAmorph, atom, block](Atom *a) {
        if (a)
        {
            block(a);
        }
        else if (!wasAmorph)
        {
            if (atom->hasAmorphNeighbour())
            {
                block(atom->amorphNeighbour());
            }
            wasAmorph = true;
        }
    });
}
#endif // NEYRON
