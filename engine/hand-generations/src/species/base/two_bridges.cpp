#include "two_bridges.h"
#include "../base/bridge.h"
#include "../specific/two_bridges_ctri_cbrs.h"

const ushort TwoBridges::Base::__indexes[2] = { 5, 0 };
const ushort TwoBridges::Base::__roles[2] = { 24, 6 };

#ifdef PRINT
const char *TwoBridges::name() const
{
    static const char value[] = "two bridges";
    return value;
}
#endif // PRINT

void TwoBridges::find(Atom *anchor)
{
    if (anchor->is(24))
    {
        if (!anchor->checkAndFind(TWO_BRIDGES, 24))
        {
            anchor->eachSpecByRole<Bridge>(6, [=](Bridge *target) {
                target->eachSymmetry([=](ParentSpec *specie) {
                    if (specie->atom(2) == anchor)
                    {
                        Atom *atom1 = specie->atom(1);
                        if (atom1->is(6))
                        {
                            ParentSpec *parent1 = atom1->specByRole<Bridge>(3);
                            if (parent1)
                            {
                                Bridge *externalLast = anchor->selectSpecByRole<Bridge>(6, [target](Bridge *other) {
                                    return other != target;
                                });

                                ParentSpec *last = externalLast->selectSymmetry([anchor](ParentSpec *other) {
                                    return other->atom(1) == anchor;
                                });

                                ParentSpec *parents[3] = { parent1, specie, last };
                                create<TwoBridges>(parents);
                            }
                        }
                    }
                });
            });
        }
    }
}

void TwoBridges::findAllChildren()
{
    TwoBridgesCTRiCBRs::find(this);
}
