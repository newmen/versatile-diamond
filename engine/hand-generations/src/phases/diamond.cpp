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
    makeLayer(0, 24, 2);
    for (int i = 1; i < _defaultSurfaceHeight; ++i)
    {
        makeLayer(i, NO_VALUE, 4);
    }
}

void Diamond::bondAllAtoms()
{
    eachAtom([this](Atom *atom) {
        assert(atom->lattice());
        bondAround(atom);
    });
}

void Diamond::detectAtomTypes()
{
    eachAtom([this](Atom *atom) {
        if (atom->type() == NO_VALUE)
        {
            ushort type = detectType(atom);
            atom->changeType(type);
        }
    });
}

Atom *Diamond::makeAtom(ushort type, ushort actives, const int3 &coords)
{
    AtomBuilder builder;
    Atom *atom = builder.buildCd(type, actives, this, coords);
    return atom;
}

bool Diamond::hasBottom(const int3 &coords)
{
    return crd_cross_110(coords).num() == 2;
}

void Diamond::findAll()
{
    Finder::initFind(atoms().data(), atoms().size());
}

ushort Diamond::detectType(const Atom *atom)
{
    ushort actives = atom->actives();
    ushort nFree = atom->amorphNeighboursNum();
    ushort nDouble = atom->doubleNeighboursNum();
    ushort nTriple = atom->tripleNeighboursNum();
    ushort nCrystal = atom->crystalNeighboursNum();
    ushort nCross_110;
    ushort nFront_110;
    if (atom->lattice() && nCrystal > 0)
    {
        nFront_110 = countCrystalNeighbours(atom, &Diamond::front_110);
        nCross_110 = countCrystalNeighbours(atom, &Diamond::cross_110);
    }
    else
    {
        nCross_110 = 0;
        nFront_110 = 0;
    }
    assert(nCrystal >= nCross_110 + nFront_110);
    assert(actives + nFree + nCrystal <= atom->valence());
    assert(actives + nDouble * 2 + nTriple * 3 + nCrystal <= atom->valence());

    if (nCross_110 == 2 &&
        nFront_110 == 2) return 24;

    else if (nCross_110 == 2 &&
             nFront_110 == 1 && actives == 1) return 5;

    else if (nCross_110 == 2 &&
             nFront_110 == 1 && actives == 0) return 34;

    else if (nCross_110 == 2 &&
             nFront_110 == 0 && actives == 2) return 2;

    else if (nCross_110 == 2 &&
             nFront_110 == 0 && actives == 1) return 28;

    else if (nCross_110 == 2 &&
             nFront_110 == 0 && actives == 0) return 0;

    else
    {
        assert(false); // undefined atom type
        return NO_VALUE;
    }
}
