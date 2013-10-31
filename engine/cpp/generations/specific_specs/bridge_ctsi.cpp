#include "bridge_ctsi.h"
#include "../handbook.h"
#include "../reactions/typical/dimer_formation.h"

void BridgeCTsi::find(BaseSpec *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(28))
    {
        if (!anchor->prevIs(28))
        {
            auto spec = new BridgeCTsi(BRIDGE_CTsi, parent);

#ifdef PRINT
            spec->wasFound();
#endif // PRINT

            anchor->describe(28, spec);

            Handbook::keeper().store<KEE_BRIDGE_CTsi>(spec);
        }
    }
    else
    {
//        if (anchor->hasRole(28, BRIDGE_CTsi))
        if (anchor->prevIs(28))
        {
            auto spec = static_cast<SpecificSpec *>(anchor->specByRole(28, BRIDGE_CTsi));
            spec->removeReactions();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchor->forget(28, BRIDGE_CTsi);
            Handbook::scavenger().storeSpec<BRIDGE_CTsi>(spec);
        }
    }
}

void BridgeCTsi::findChildren()
{
    DimerFormation::find(this);
}
