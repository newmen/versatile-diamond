#include "dimer_crs.h"
#include "../handbook.h"
#include "../reactions/typical/methyl_to_dimer.h"

void DimerCRs::find(Dimer *parent)
{
    uint indexes[2] = { 0, 3 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = parent->atom(indexes[i]);
        if (anchor->isVisited()) continue;

        if (anchor->is(21))
        {
            if (!anchor->prevIs(21))
            {
                auto spec = new DimerCRs(DIMER_CRs, parent, indexes[i]);

#ifdef PRINT
                spec->wasFound();
#endif // PRINT

                anchor->describe(21, spec);
                spec->findChildren();
            }
        }
        else
        {
            if (anchor->prevIs(21))
            {
                auto spec = anchor->specificSpecByRole(21, DIMER_CRs);
                spec->removeReactions();

#ifdef PRINT
                spec->wasForgotten();
#endif // PRINT

                anchor->forget(21, spec);
                Handbook::scavenger.markSpec<DIMER_CRs>(spec);
            }
        }
    }
}

Atom *DimerCRs::atom(ushort index)
{
    ushort shiftedIndex = index + _atomsShift;
    if (shiftedIndex >= size()) shiftedIndex -= size();
    return SpecificSpec::atom(shiftedIndex);
}

void DimerCRs::findChildren()
{
    MethylToDimer::find(this);
}
