#include "finder.h"
#include "handbook.h"

#include "species/base/bridge.h"
#include "species/base/dimer.h"
#include "reactions/ubiquitous/surface_activation.h"
#include "reactions/ubiquitous/surface_deactivation.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

void Finder::initFind(Atom **atoms, int n)
{
    // TODO: refactor it? for get only instanced atoms

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

    Handbook::keeper().findReactions();

    for (int i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (!atom) continue;
        atom->setVisited();
    }

    finalize();

    Handbook::mc().sort();
}

void Finder::findAll(Atom **atoms, int n)
{
#ifdef PRINT
    debugPrintWoLock([&](std::ostream &os) {
        os << "Find by " << n << " atoms";
        for (int i = 0; i < n; ++i)
        {
            os << " [" << atoms[i] << "]";
        }
    });
#endif // PRINT

#ifdef DEBUG
    for (int i = 0; i < n; ++i)
    {
        assert(atoms[i]);
    }
#endif // DEBUG

    for (int i = 0; i < n; ++i)
    {
        atoms[i]->setUnvisited();
    }

    for (int i = 0; i < n; ++i)
    {
        atoms[i]->removeUnsupportedSpecies();
    }

    for (int i = 0; i < n; ++i)
    {
        atoms[i]->setSpecsUnvisited();
    }

    for (int i = 0; i < n; ++i)
    {
        Bridge::find(atoms[i]);
    }

    for (int i = 0; i < n; ++i)
    {
        Dimer::find(atoms[i]);
    }

    for (int i = 0; i < n; ++i)
    {
        atoms[i]->findUnvisitedChildren();
    }

    for (int i = 0; i < n; ++i)
    {
        SurfaceActivation::find(atoms[i]);
        SurfaceDeactivation::find(atoms[i]);
    }

    Handbook::keeper().findReactions();

    for (int i = 0; i < n; ++i)
    {
        atoms[i]->setVisited();
    }

    finalize();
}

void Finder::removeAll(Atom **atoms, int n)
{
    for (int i = 0; i < n; ++i)
    {
        Atom *atom = atoms[i];
        if (!atom) continue;
        atom->prepareToRemove();
    }

    initFind(atoms, n);
}

void Finder::finalize()
{
    Handbook::keeper().clear();
    Handbook::scavenger().clear();
}
