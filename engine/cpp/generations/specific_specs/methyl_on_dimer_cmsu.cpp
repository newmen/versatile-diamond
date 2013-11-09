#include "methyl_on_dimer_cmsu.h"
#include "../handbook.h"
#include "../reactions/typical/methyl_to_high_bridge.h"

void MethylOnDimerCMsu::find(MethylOnDimerCMu *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(29))
    {
        if (!anchor->hasRole(29, METHYL_ON_DIMER_CMsu))
        {
            auto spec = new MethylOnDimerCMsu(METHYL_ON_DIMER_CMsu, parent);

#ifdef PRINT
            spec->wasFound();
#endif // PRINT

            anchor->describe(29, spec);
            spec->findChildren();
        }
    }
    else
    {
        auto spec = anchor->specificSpecByRole(29, METHYL_ON_DIMER_CMsu);
        if (spec)
        {
            spec->removeReactions();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchor->forget(29, spec);

            Handbook::scavenger().markSpec<METHYL_ON_DIMER_CMsu>(spec);
        }
    }
}

void MethylOnDimerCMsu::findChildren()
{
    MethylToHighBridge::find(this);
}
