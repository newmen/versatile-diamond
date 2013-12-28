#include "two_bridges.h"
#include "bridge.h"
#include "../specific/two_bridges_cbrs.h"

ushort TwoBridges::__indexes[3] = { 0, 1, 4 };
ushort TwoBridges::__roles[3] = { 0, 6, 24 };

void TwoBridges::find(Atom *anchor)
{
    if (anchor->is(24) && anchor->lattice()->coords().z > 0)
    {
        if (!checkAndFind<TwoBridges>(anchor, 24))
        {
            const Diamond::RelationsMethod relations[2] = {
                &Diamond::front_110,
                &Diamond::front_100
            };

            eachRelations<2>(anchor, relations, [anchor](Atom **neighbours) {
                Atom *top = neighbours[0], *bottom = neighbours[1];

                //  || top->is(19)
                if (top->is(0) && bottom->is(6))
                {
                    assert(top->hasBondWith(anchor));
                    assert(top->hasBondWith(bottom));

                    assert(top->hasRole<Bridge>(3));
                    assert(top->lattice());
                    assert(bottom->hasRole<Bridge>(3));
                    assert(bottom->lattice());

                    auto first = anchor->findSpecByRole<Bridge>(6, [bottom] (BaseSpec *spec) {
                        return !bottom->hasSpec(6, spec);
                    });

                    assert(first);

                    ParentSpec *parents[2] = {
                        first,
                        bottom->specByRole<Bridge>(3)
                    };

                    create<TwoBridges>(top, parents);
                }
            });
        }
    }
}

void TwoBridges::findAllChildren()
{
    TwoBridgesCBRs::find(this);
}
