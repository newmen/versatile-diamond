#include "methyl_on_dimer.h"
#include "../specific/methyl_on_dimer_cmu.h"
#include "../../reactions/ubiquitous/local/methyl_on_dimer_activation.h"
#include "../../reactions/ubiquitous/local/methyl_on_dimer_deactivation.h"

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
            if (!checkAndFind<MethylOnDimer>(anchor, 23) && !anchor->isVisited())
            {
                Atom *methyl = anchor->amorphNeighbour();
                if (methyl->is(14))
                {
                    createBy<MethylOnDimer>(&methyl, checkingIndexes[i], target);
                }
            }
        }
    }
}

void MethylOnDimer::store()
{
    Base::store();

    Atom *target = this->atom(0);
    if (target->isVisited())
    {
        MethylOnDimerActivation::concretize(target);
        MethylOnDimerDeactivation::concretize(target);
    }
}

void MethylOnDimer::remove()
{
    Base::remove();

    Atom *target = this->atom(0);
    if (target->isVisited())
    {
        MethylOnDimerActivation::unconcretize(target);
        MethylOnDimerDeactivation::unconcretize(target);
    }
}

void MethylOnDimer::findAllChildren()
{
    MethylOnDimerCMu::find(this);
}
