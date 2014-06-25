#include "two_bridges.h"
#include "../base/bridge.h"
#include "../specific/two_bridges_ctri_cbrs.h"

const ushort TwoBridges::__indexes[1] = { 5 };
const ushort TwoBridges::__roles[1] = { 24 };

#ifdef PRINT
const char *TwoBridges::name() const
{
    static const char value[] = "two bridges";
    return value;
}
#endif // PRINT

void TwoBridges::find(Atom *anchor)
{
    if (anchor->is(24) && anchor->lattice()->coords().z > 0)
    {
        if (!anchor->checkAndFind(TWO_BRIDGES, 24))
        {
            ParentSpec *topBridges[2] = { nullptr, nullptr };
            ushort index = 0;

            anchor->eachSpecByRole<Bridge>(6, [&topBridges, &index, anchor](Bridge *target) {
                target->eachSymmetry([&topBridges, anchor, index](ParentSpec *specie) {
                    if (specie->atom(2) == anchor)
                    {
                        assert(!topBridges[index]);
                        topBridges[index] = specie;
                    }
                });
                ++index;
            });

            for (uint i = 0; i < 2; ++i)
            {
                uint o = 1 - i;
                ParentSpec *targets[3] = {
                    topBridges[i]->atom(1)->specByRole<Bridge>(3),
                    topBridges[i],
                    topBridges[o]
                };

                create<TwoBridges>(targets);
            }
        }
    }
}

void TwoBridges::findAllChildren()
{
    TwoBridgesCTRiCBRs::find(this);
}
