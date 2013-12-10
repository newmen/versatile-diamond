#include "dimer.h"
#include <assert.h>
#include "../../../species/lateral_reactant.h"
#include "../specific/dimer_cri_cli.h"
#include "../specific/dimer_crs.h"
#include "methyl_on_dimer.h"

ushort Dimer::__indexes[2] = { 0, 3 };
ushort Dimer::__roles[2] = { 22, 22 };

void Dimer::find(Atom *anchor)
{
    if (anchor->is(22))
    {
        if (!checkAndFind(anchor, 22, DIMER))
        {
            auto diamond = crystalBy<Diamond>(anchor);
            eachNeighbour(anchor, diamond, &Diamond::front_100, [anchor](Atom *neighbour) {
                if (anchor->hasBondWith(neighbour))
                {
                    assert(neighbour->hasRole(3, BRIDGE));
                    assert(neighbour->is(22));
                    assert(neighbour->lattice());

                    BaseSpec *parents[2] = {
                        anchor->specByRole<BaseSpec>(3, BRIDGE),
                        neighbour->specByRole<BaseSpec>(3, BRIDGE)
                    };

                    createBy<LateralReactant>(new Dimer(parents));
                }
            });
        }
    }
}

void Dimer::findAllChildren()
{
    MethylOnDimer::find(this);
    DimerCRiCLi::find(this);
    DimerCRs::find(this);
}
