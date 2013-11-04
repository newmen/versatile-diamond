#include "methyl_on_dimer_cls_cmu.h"
#include "../handbook.h"
#include "../reactions/typical/methyl_on_dimer_hydrogen_migration.h"

void MethylOnDimerCLsCMu::find(MethylOnDimerCMu *parent)
{
    Atom *anchor = parent->atom(4);

    if (anchor->is(21))
    {
        if (!anchor->hasRole(21, METHYL_ON_DIMER_CLs_CMu))
        {
            auto spec = new MethylOnDimerCLsCMu(METHYL_ON_DIMER_CLs_CMu, parent);

#ifdef PRINT
            spec->wasFound();
#endif // PRINT

            anchor->describe(21, spec);
            spec->findChildren();
        }
    }
    else
    {
        auto spec = anchor->specificSpecByRole(21, METHYL_ON_DIMER_CLs_CMu);
        if (spec)
        {
            spec->removeReactions();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchor->forget(21, spec);
            Handbook::scavenger.markSpec<METHYL_ON_DIMER_CLs_CMu>(spec);
        }
    }
}

void MethylOnDimerCLsCMu::findChildren()
{
    MethylOnDimerHydrogenMigration::find(this);
}
