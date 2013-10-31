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

void Finder::findByOne(Atom *atom, bool checkNull)
{
#ifdef PRINT
    std::cout << "Find by one atom [" << atom << "]" << std::endl;
#endif // PRINT

#ifdef DEBUG
    if (checkNull && !atom) assert(true);
#endif // DEBUG

    atom->setUnvisited(); // TODO: do not used?

#ifdef PARALLEL
#pragma omp parallel sections
    {
#pragma omp section
        {
#endif // PARALLEL
            // finds bridge and all their children with mono (+ gas) reactions with it
            Bridge::find(atom);
#ifdef PARALLEL
        }
#pragma omp section
        {
#endif // PARALLEL
            SurfaceActivation::find(atom);
            SurfaceDeactivation::find(atom);
#ifdef PARALLEL
        }
    }
#endif // PARALLEL

    Dimer::find(atom);
    Handbook::keeper().findAll();

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

#ifdef PARALLEL
#pragma omp parallel
    {
#endif // PARALLEL

#ifdef DEBUG
#ifdef PARALLEL
#pragma omp for schedule(dynamic) nowait
#endif // PARALLEL
        for (int i = 0; i < n; ++i)
        {
            Atom *atom = atoms[i];
            if (isInit && !atom) assert(true);
        }
#endif // DEBUG

#ifdef PARALLEL
#pragma omp for schedule(dynamic)
#endif // PARALLEL
        for (int i = 0; i < n; ++i)
        {
            Atom *atom = atoms[i];
            if (!atom) continue;
            atom->setUnvisited();
        }

#ifdef PARALLEL
#pragma omp for schedule(dynamic)
#endif // PARALLEL
        for (int i = 0; i < n; ++i)
        {
            Atom *atom = atoms[i];
            if (!atom) continue;

#ifdef PARALLEL
#pragma omp parallel sections
            {
#pragma omp section
                {
#endif // PARALLEL
                    // finds bridge and all their children with mono (+ gas) reactions with it
                    Bridge::find(atom);
#ifdef PARALLEL
                }
#pragma omp section
                {
#endif // PARALLEL
                    SurfaceActivation::find(atom);
                    SurfaceDeactivation::find(atom);
#ifdef PARALLEL
                }
            }
#endif // PARALLEL
        }

#ifdef PARALLEL
#pragma omp for schedule(dynamic)
#endif // PARALLEL
        for (int i = 0; i < n; ++i)
        {
            Atom *atom = atoms[i];
            if (!atom) continue;

//#ifdef PARALLEL
//#pragma omp parallel sections
//            {
//#pragma omp section
//                {
//#endif // PARALLEL
                    // finds dimer and all their children with mono (+ gas) reactions with it
                    Dimer::find(atom);
//#ifdef PARALLEL
//                }
//#pragma omp section
//                {
//#endif // PARALLEL
//                    TwoBridges::find(atom);
//#ifdef PARALLEL
//                }
//            }
//#endif // PARALLEL
        }

        Handbook::keeper().findAll();

#ifdef PARALLEL
#pragma omp for schedule(dynamic)
#endif // PARALLEL
        for (int i = 0; i < n; ++i)
        {
            Atom *atom = atoms[i];
            if (!atom) continue;
            atom->setVisited();
        }

#ifdef PARALLEL
    }
#endif // PARALLEL

    finalize();

    if (isInit)
    {
        Handbook::mc().sort();
    }
}

void Finder::finalize()
{
#ifdef PARALLEL
#pragma omp parallel sections
    {
#pragma omp section
        {
#endif // PARALLEL
            Handbook::keeper().clear();
#ifdef PARALLEL
        }
#pragma omp section
        {
#endif // PARALLEL
            Handbook::scavenger().clear();
#ifdef PARALLEL
        }
    }
#endif // PARALLEL
}
