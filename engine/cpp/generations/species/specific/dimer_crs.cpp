#include "dimer_crs.h"
#include "../../reactions/typical/ads_methyl_to_dimer.h"

ushort DimerCRs::__indexes[1] = { 0 };
ushort DimerCRs::__roles[1] = { 21 };

void DimerCRs::find(Dimer *parent)
{
    uint indexes[2] = { 0, 3 };

    for (int i = 0; i < 2; ++i)
    {
        Atom *anchor = parent->atom(indexes[i]);
        if (anchor->isVisited()) continue; // because no children species

        if (anchor->is(21))
        {
            if (!anchor->hasRole(21, DIMER_CRs))
            {
                auto spec = new DimerCRs(indexes[i], parent);
                spec->store();
            }
        }
    }
}

void DimerCRs::findChildren()
{
    AdsMethylToDimer::find(this);
}
