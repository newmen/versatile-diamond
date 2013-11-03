#include "methyl_on_dimer_cls.h"
#include "../handbook.h"
#include "../reactions/typical/methyl_on_dimer_hydrogen_migration.h"

void MethylOnDimerCLs::find(MethylOnDimer *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(4) };

    if (anchors[0]->is(25) && !anchors[0]->is(13) && anchors[1]->is(21))
    {
        if (!anchors[0]->hasRole(25, METHYL_ON_DIMER_CLs) && !anchors[1]->hasRole(21, METHYL_ON_DIMER_CLs))
        {
            auto spec = new MethylOnDimerCLs(METHYL_ON_DIMER_CLs, parent);

#ifdef PRINT
            spec->wasFound();
#endif // PRINT

            anchors[0]->describe(25, spec);
            anchors[1]->describe(21, spec);

            spec->findChildren();
        }
    }
    else
    {
        if (anchors[0]->hasRole(25, METHYL_ON_DIMER_CLs) && anchors[1]->hasRole(21, METHYL_ON_DIMER_CLs))
        {
            auto spec = anchors[0]->specificSpecByRole(25, METHYL_ON_DIMER_CLs);
            spec->removeReactions();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchors[0]->forget(25, spec);
            anchors[1]->forget(21, spec);

            Handbook::scavenger.markSpec<METHYL_ON_DIMER_CLs>(spec);
        }
    }
}

void MethylOnDimerCLs::findChildren()
{
    MethylOnDimerHydrogenMigration::find(this);
}
