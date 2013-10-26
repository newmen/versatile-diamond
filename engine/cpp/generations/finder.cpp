#include "finder.h"
#include "handbook.h"

#include "base_specs/bridge.h"
#include "base_specs/dimer.h"
#include "reactions/ubiquitous/surface_activation.h"
#include "reactions/ubiquitous/surface_deactivation.h"

#include <omp.h>

void Finder::findAll(Atom **atoms, int n, bool checkNull)
{
#pragma omp parallel
    {
#ifdef DEBUG
#pragma omp for schedule(dynamic)
        for (int i = 0; i < n; ++i)
        {
            Atom *atom = atoms[i];
            if (checkNull && !atom) assert(true);
            if (!atom) continue;
        }
#endif // DEBUG

#pragma omp for schedule(dynamic)
        for (int i = 0; i < n; ++i)
        {
            Atom *atom = atoms[i];
            if (!atom) continue;
            atom->setUnvisited();
        }

#pragma omp for schedule(dynamic)
        for (int i = 0; i < n; ++i)
        {
            Atom *atom = atoms[i];
            if (!atom) continue;

#pragma omp parallel sections
            {
#pragma omp section
                {
                    // finds bridge and all their children with mono (+ gas) reactions with it
                    Bridge::find(atom);
                }
//#pragma omp section
//                {
//                    ReactionActivation::find(atom);
//                }
//#pragma omp section
//                {
//                    ReactionDeactivation::find(atom);
//                }
            }
        }

#pragma omp for schedule(dynamic)
        for (int i = 0; i < n; ++i)
        {
            Atom *atom = atoms[i];
            if (!atom) continue;

#pragma omp parallel sections
            {
#pragma omp section
                {
                    // finds dimer and all their children with mono (+ gas) reactions with it
                    Dimer::find(atom);
                }
//#pragma omp section
//                {
//                    TwoBridges::find(atom);
//                }
            }
        }

        Handbook::keeper().findAll();

#pragma omp for schedule(dynamic)
        for (int i = 0; i < n; ++i)
        {
            Atom *atom = atoms[i];
            if (!atom) continue;
            atom->setVisited();
        }
    }

#pragma omp parallel sections
    {
#pragma omp section
        {
            Handbook::keeper().clear();
        }
#pragma omp section
        {
            Handbook::scavenger().clear();
        }
    }
}
