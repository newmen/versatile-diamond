#include "methyl_on_dimer.h"
#include "../specific/methyl_on_dimer_cmu.h"

ushort MethylOnDimer::__indexes[2] = { 1, 0 };
ushort MethylOnDimer::__roles[2] = { 23, 14 };

void MethylOnDimer::find(Dimer *target)
{
    uint checkingIndexes[2] = { 0, 3 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = target->atom(checkingIndexes[i]);

        if (anchor->is(23))
        {
            if (!checkAndFind(anchor, 23, METHYL_ON_DIMER) && !anchor->isVisited())
            {
                Atom *methyl = anchor->amorphNeighbour();
                if (methyl->is(14))
                {
                    BaseSpec *parent = target;
                    createBy<MethylOnDimer>(&methyl, checkingIndexes[i], &parent);
                }
            }
        }
    }
}

void MethylOnDimer::findAllChildren()
{
    MethylOnDimerCMu::find(this);
}
