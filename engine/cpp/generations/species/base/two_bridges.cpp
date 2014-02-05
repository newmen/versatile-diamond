#include "two_bridges.h"
#include "bridge.h"
#include "../specific/two_bridges_cbrs.h"

const ushort TwoBridges::__indexes[1] = { 0 };
const ushort TwoBridges::__roles[1] = { 0 };

void TwoBridges::find(Bridge *parent)
{
    Atom *anchor = parent->atom(0);
    assert(anchor->lattice());

    if (anchor->is(0) && anchor->lattice()->coords().z > 1)
    {
        const ushort bottomIndexes[2] = { 1, 2 };
        const ushort nearIndexes[2] = { 2, 1 };

        for (int i = 0; i < 2; ++i)
        {
            Atom *bottomAnchor = parent->atom(bottomIndexes[i]);
            Atom *nearAnchor = parent->atom(nearIndexes[i]);

            assert(bottomAnchor->is(6));
            if (nearAnchor->is(24))
            {
                auto bottom = bottomAnchor->specByRole<Bridge>(3);
                assert(bottom);

                auto near = nearAnchor->findSpecByRole<Bridge>(6, [parent](BaseSpec *spec) {
                    return spec != parent;
                });
                assert(near);

                ParentSpec *parents[] = {
                    parent,
                    bottom,
                    near
                };

                create<TwoBridges>(bottomIndexes[i], 1, parents);
                break;
            }
        }
    }
}

void TwoBridges::findAllChildren()
{
    TwoBridgesCBRs::find(this);
}
