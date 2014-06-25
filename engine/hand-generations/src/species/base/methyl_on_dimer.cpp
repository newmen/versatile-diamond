#include "methyl_on_dimer.h"
#include "../specific/methyl_on_dimer_cmiu.h"

const ushort MethylOnDimer::__indexes[2] = { 1, 0 };
const ushort MethylOnDimer::__roles[2] = { 23, 14 };

#ifdef PRINT
const char *MethylOnDimer::name() const
{
    static const char value[] = "methyl on dimer";
    return value;
}
#endif // PRINT

void MethylOnDimer::find(Dimer *target)
{
    target->eachSymmetry([](ParentSpec *specie) {
        Atom *anchor = specie->atom(0);

        if (anchor->is(23))
        {
            if (!anchor->checkAndFind(METHYL_ON_DIMER, 23) && !anchor->isVisited())
            {
                Atom *amorph = anchor->amorphNeighbour();
                if (amorph->is(14))
                {
                    create<MethylOnDimer>(amorph, specie);
                }
            }
        }
    });
}

void MethylOnDimer::findAllChildren()
{
    MethylOnDimerCMiu::find(this);
}
