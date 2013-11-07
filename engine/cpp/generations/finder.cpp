#include "finder.h"
#include "handbook.h"

#include "base_specs/bridge.h"
#include "base_specs/dimer.h"
#include "reactions/ubiquitous/surface_activation.h"
#include "reactions/ubiquitous/surface_deactivation.h"

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

#ifdef PRINT
#include <iostream>
#endif // PRINT

#include <iostream>

void Finder::findAll(Atom **atoms, int n, bool isInit)
{
    if (n == 1) findByOne(*atoms, isInit);
    else findByMany(atoms, n, isInit);
}

void Finder::removeAll(Atom **atoms, int n)
{
#ifdef PARALLEL
#pragma omp parallel for schedule(dynamic)
#endif // PARALLEL
    for (int i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (atom)
        {
            atom->prepareToRemove();
        }
    }

    findByMany(atoms, n, false);
}

void Finder::findByOne(Atom *atom, bool checkNull)
{
#ifdef PRINT
    std::cout << "Find by one atom [" << atom << "]" << std::endl;
#endif // PRINT

#ifdef DEBUG
    if (checkNull && !atom) assert(true);
#endif // DEBUG

    atom->setUnvisited(); // TODO: do not used?

    // finds bridge and all their children with mono (+ gas) reactions with it
    Bridge::find(atom);
    Dimer::find(atom);

    {
        SurfaceActivation::find(atom);
        SurfaceDeactivation::find(atom);
    }

    Handbook::keeper.findAll();

    atom->setVisited(); // TODO: do not used?

    finalize();
}

void Finder::findByMany(Atom **atoms, int n, bool isInit)
{
#ifdef PRINT
    if (isInit)
    {
        std::cout << "Find by many atoms";
        for (int i = 0; i < n; ++i)
        {
            std::cout << " [" << atoms[i] << "]";
        }
        std::cout << std::endl;
    }
#endif // PRINT


#ifdef DEBUG
    for (int i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (isInit && !atom) assert(true);
    }
#endif // DEBUG

    for (int i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (!atom) continue;
        atom->setUnvisited();
    }

    for (int i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (!atom) continue;

        Bridge::find(atom);
    }

    for (int i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (!atom) continue;

        Dimer::find(atom);
    }

    for (int i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (!atom) continue;

        SurfaceActivation::find(atom);
        SurfaceDeactivation::find(atom);
    }

    Handbook::keeper.findAll();

    for (int i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (!atom) continue;
        atom->setVisited();
    }

    finalize();

    if (isInit)
    {
        Handbook::mc.sort();
    }
}

void Finder::finalize()
{
    Handbook::keeper.clear();
    Handbook::scavenger.clear();
}
