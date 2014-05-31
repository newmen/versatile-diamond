#include "methyl_on_dimer.h"
#include "../../reactions/ubiquitous/local/methyl_on_dimer_activation.h"
#include "../../reactions/ubiquitous/local/methyl_on_dimer_deactivation.h"
#include "../empty/shifted_dimer.h"
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
    MethylOnDimerCMiu::find(this);
}

void MethylOnDimer::concretizeLocal(Atom *target) const
{
    MethylOnDimerActivation::concretize(target);
    MethylOnDimerDeactivation::concretize(target);
}

void MethylOnDimer::unconcretizeLocal(Atom *target) const
{
    MethylOnDimerActivation::unconcretize(target);
    MethylOnDimerDeactivation::unconcretize(target);
}
