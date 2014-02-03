#include "finder.h"
#include "handbook.h"

#include "species/base/bridge.h"
#include "species/sidepiece/dimer.h"
#include "reactions/ubiquitous/surface_activation.h"
#include "reactions/ubiquitous/surface_deactivation.h"

void Finder::initFind(Atom **atoms, uint n)
{
    uint index = 0;
    Atom **dup = new Atom *[n];
    for (uint i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (!atom) continue;

        dup[index++] = atom;
    }

    findAll(dup, index);

    delete [] dup;

    finalize();

    Handbook::mc().sort();
}

void Finder::findAll(Atom **atoms, uint n)
{
#ifdef PRINT
    debugPrint([&](std::ostream &os) {
        os << "Find by " << n << " atoms";
        for (uint i = 0; i < n; ++i)
        {
            os << " [" << atoms[i] << "]";
        }
    });
#endif // PRINT

#ifndef NDEBUG
    for (uint i = 0; i < n; ++i)
    {
        assert(atoms[i]);
    }
#endif // NDEBUG

    for (uint i = 0; i < n; ++i)
    {
        atoms[i]->setUnvisited();
    }

    for (uint i = 0; i < n; ++i)
    {
        atoms[i]->removeUnsupportedSpecies();
    }

    for (uint i = 0; i < n; ++i)
    {
        atoms[i]->setSpecsUnvisited();
    }

    for (uint i = 0; i < n; ++i)
    {
        Bridge::find(atoms[i]);
    }

    for (uint i = 0; i < n; ++i)
    {
        Dimer::find(atoms[i]);
    }

    for (uint i = 0; i < n; ++i)
    {
        atoms[i]->findUnvisitedChildren();
    }

    Handbook::componentKeeper().findComplexSpecies();

    for (uint i = 0; i < n; ++i)
    {
        SurfaceActivation::find(atoms[i]);
        SurfaceDeactivation::find(atoms[i]);
    }

    // order is important
    Handbook::specificKeeper().findReactions();
    Handbook::lateralKeeper().findReactions();

    for (uint i = 0; i < n; ++i)
    {
        atoms[i]->setVisited();
    }

    finalize();
}

void Finder::removeAll(Atom **atoms, uint n)
{
    for (uint i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (!atom) continue;
        atom->prepareToRemove();
    }

    initFind(atoms, n);
}

void Finder::finalize()
{
    Handbook::componentKeeper().clear();
    Handbook::specificKeeper().clear();
    Handbook::lateralKeeper().clear();

    Handbook::scavenger().clear();
}
