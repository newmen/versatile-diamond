#include "finder.h"
#include "handbook.h"

#include "species/base/bridge.h"
#include "species/base/dimer.h"
#include "reactions/ubiquitous/surface_activation.h"
#include "reactions/ubiquitous/surface_deactivation.h"

#ifdef PRINT
#include <iostream>
#endif // PRINT

#include <iostream>

void Finder::findAll(Atom **atoms, int n, bool isInit)
{
#ifdef PRINT
    if (!isInit)
    {
        std::cout << "Find by " << n << " atoms";
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
        if (!isInit && !atom) assert(true);
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
        atom->removeUnsupportedSpecies();
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

    Handbook::keeper().findAll();

    for (int i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (!atom) continue;
        atom->setVisited();
    }

    Handbook::keeper().clear();
    Handbook::scavenger().clear();

    if (isInit)
    {
        Handbook::mc().sort();
    }
}

void Finder::removeAll(Atom **atoms, int n)
{
    for (int i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (atom)
        {
            atom->prepareToRemove();
        }
    }

    findAll(atoms, n, false);
}
