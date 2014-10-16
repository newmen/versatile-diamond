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
            anchor->eachSpecByRole<Bridge>(6, [=](Bridge *target1) {
                target1->eachSymmetry([=](ParentSpec *specie1) {
                    if (specie1->atom(2) == anchor)
                    {
                        Bridge *target2 = anchor->selectSpecByRole<Bridge>(6, [target1](Bridge *other) {
                            return other != target1;
                        });

                        ParentSpec *specie2 = target2->selectSymmetry([anchor](ParentSpec *other) {
                            return other->atom(1) == anchor;
                        });

                        Atom *atom1 = specie1->atom(1);
                        ParentSpec *parents[3] = { atom1->specByRole<Bridge>(3), specie1, specie2 };
                        create<TwoBridges>(parents);
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
