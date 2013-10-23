#include "finder.h"
#include "handbook.h"

#include "base_specs/bridge.h"
#include "base_specs/dimer.h"
#include "reactions/ubiquitous/reaction_activation.h"
#include "reactions/ubiquitous/reaction_deactivation.h"

#include <omp.h>

void Finder::findAll(Atom **atoms, int n, bool checkNull)
{
#pragma omp parallel
    {
#pragma omp for schedule(dynamic)
        for (int i = 0; i < n; ++i)
        {
            Atom *atom = atoms[i];
#ifdef DEBUG
            if (checkNull && !atom) assert(true);
#endif // DEBUG
            if (!atom) continue;
            if (atom) atom->specifyType();
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
                    Bridge::find(atom);
                    // finds bridge and all their children with mono (+ gas) reactions with it
                }
#pragma omp section
                {
                    ReactionActivation::find(atom);
                }
#pragma omp section
                {
                    ReactionDeactivation::find(atom);
                }
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
                    Dimer::find(atom);
                    // finds dimer and all their children with mono (+ gas) reactions with it
                }
//#pragma omp section
//                {
//                    TwoBridges::find(atom);
//                }
            }
        }

        Handbook::keeper().findAll();
    }

    Handbook::keeper().clear();
}
