#include "methyl_on_dimer.h"
#include "../specific/methyl_on_dimer_cmiu.h"

template <> const ushort MethylOnDimer::Base::__indexes[2] = { 1, 4 };
template <> const ushort MethylOnDimer::Base::__roles[2] = { 23, 22 };

#if defined(PRINT) || defined(SERIALIZE)
const char *MethylOnDimer::name() const
{
    static const char value[] = "methyl on dimer";
    return value;
}
#endif // PRINT || SERIALIZE

void MethylOnDimer::find(Atom *anchor)
{
    if (anchor->is(23))
    {
        if (!anchor->checkAndFind(METHYL_ON_DIMER, 23))
        {
            eachNeighbour(anchor, &Diamond::front_100, [anchor](Atom *neighbour) {
                if (neighbour->is(22) && anchor->hasBondWith(neighbour))
                {
                    assert(neighbour->hasRole(BRIDGE, 3));
                    assert(neighbour->lattice());

                    ParentSpec *parents[2] = {
                        anchor->specByRole<MethylOnBridge>(9),
                        neighbour->specByRole<Bridge>(3)
                    };

                    create<MethylOnDimer>(parents);
                }
            });
        }
    }
    else if (anchor->is(22))
    {
        if (!anchor->checkAndFind(METHYL_ON_DIMER, 22))
        {
            eachNeighbour(anchor, &Diamond::front_100, [anchor](Atom *neighbour) {
                if (neighbour->is(23) && anchor->hasBondWith(neighbour))
                {
                    assert(neighbour->hasRole(METHYL_ON_BRIDGE, 9));
                    assert(neighbour->lattice());

                    ParentSpec *parents[2] = {
                        neighbour->specByRole<MethylOnBridge>(9),
                        anchor->specByRole<Bridge>(3)
                    };

                    create<MethylOnDimer>(parents);
                }
            });
        }
    }
}

void MethylOnDimer::findAllChildren()
{
    MethylOnDimerCMiu::find(this);
}
