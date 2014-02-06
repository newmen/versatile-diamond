#include "methyl_on_dimer.h"
#include "../dolls/shifted_dimer.h"
#include "../specific/methyl_on_dimer_cmu.h"

const ushort MethylOnDimer::__indexes[2] = { 1, 0 };
const ushort MethylOnDimer::__roles[2] = { 23, 14 };

void MethylOnDimer::find(Dimer *target)
{
    const ushort checkingIndexes[2] = { 0, 3 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = target->atom(checkingIndexes[i]);

        if (anchor->is(23))
        {
            if (!anchor->checkAndFind(METHYL_ON_DIMER, 23) && !anchor->isVisited())
            {
                Atom *amorph = anchor->amorphNeighbour();
                if (amorph->is(14))
                {
                    if (checkingIndexes[i] == 0)
                    {
                        create<MethylOnDimer>(amorph, target);
                    }
                    else
                    {
                        auto shiftedDimer = create<ShiftedDimer>(target);
                        create<MethylOnDimer>(amorph, shiftedDimer);
                    }
                }
            }
        }
    }
}

void MethylOnDimer::findAllChildren()
{
    MethylOnDimerCMu::find(this);
}
