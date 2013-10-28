#include "dimer.h"
#include "../handbook.h"

#include <assert.h>

#ifdef PRINT
#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL
#include <iostream>
#endif // PRINT

void Dimer::find(Atom *anchor)
{
    assert(anchor);

#ifdef PRINT
    std::cout << "dm find: [" << anchor << "] -> ";
    std::cout << anchor->type() << " at " << anchor->lattice()->coords();
    std::cout.flush();
    std::cout << " is 22? " << anchor->is(22);
    if (anchor->is(22)) std::cout << ". and hasRole 3.bridge? " << anchor->hasRole(3, BRIDGE);
    std::cout << std::endl;
#endif // PRINT

    if (!anchor->is(22) && anchor->hasRole(3, BRIDGE)) return;
    if (!anchor->prevIs(22)) // TODO: здесь нужно подумать, поскольку роль не проверяется
    {
        assert(anchor->lattice());

        auto diamond = dynamic_cast<const Diamond *>(anchor->lattice()->crystal());
        assert(diamond);

        auto nbrs = diamond->front_100(anchor);
        if (nbrs[0] && nbrs[0]->is(22) && anchor->hasBondWith(nbrs[0]) && nbrs[0]->hasRole(3, BRIDGE))
        {
            assert(nbrs[0]->lattice());

            BaseSpec *parents[2] = {
                anchor->specByRole(3, BRIDGE),
                nbrs[0]->specByRole(3, BRIDGE)
            };
            auto dimer = std::shared_ptr<BaseSpec>(new Dimer(DIMER, parents));

            anchor->describe(22, dimer);
            nbrs[0]->describe(22, dimer);

#ifdef PRINT
#ifdef PARALLEL
#pragma omp critical
            {
#endif // PARALLEL
                std::cout << "Dimer at ";
                dimer->info();
                std::cout << " was found" << std::endl;
#ifdef PARALLEL
            }
#endif // PARALLEL
#endif // PRINT

            dimer->findChildren();
        }
    }
}

void Dimer::findChildren()
{

}

