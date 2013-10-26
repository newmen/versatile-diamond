#include "finder.h"
#include "handbook.h"

#include "base_specs/bridge.h"
#include "base_specs/dimer.h"
#include "reactions/ubiquitous/surface_activation.h"
#include "reactions/ubiquitous/surface_deactivation.h"

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

void Finder::findAll(Atom **atoms, int n, bool checkNull)
{
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
            if (checkNull && !atom) assert(true);
            if (!atom) continue;
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
#ifdef PARALLEL
                }
#pragma omp section
                {
#endif // PARALLEL
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

#ifdef PARALLEL
#pragma omp parallel sections
            {
#pragma omp section
                {
#endif // PARALLEL
                    // finds dimer and all their children with mono (+ gas) reactions with it
                    Dimer::find(atom);
#ifdef PARALLEL
                }
//#pragma omp section
//                {
//                    TwoBridges::find(atom);
//                }
            }
#endif // PARALLEL
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
