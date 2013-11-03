#include "methyl_on_dimer_cms.h"
#include "../handbook.h"
#include "../reactions/typical/methyl_to_high_bridge.h"

void MethylOnDimerCMs::find(MethylOnDimer *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(26))
    {
        if (!anchor->hasRole(26, METHYL_ON_DIMER_CMs))
        {
            auto spec = new MethylOnDimerCMs(METHYL_ON_DIMER_CMs, parent);

#ifdef PRINT
            spec->wasFound();
#endif // PRINT

            anchor->describe(26, spec);
            spec->findChildren();
        }
    }
    else
    {
        if (anchor->hasRole(26, METHYL_ON_DIMER_CMs))
        {
            auto spec = anchor->specificSpecByRole(26, METHYL_ON_DIMER_CMs);
            spec->removeReactions();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchor->forget(26, spec);
            Handbook::scavenger.markSpec<METHYL_ON_DIMER_CMs>(spec);
        }
    }
}

void MethylOnDimerCMs::findChildren()
{
    MethylToHighBridge::find(this);
}
