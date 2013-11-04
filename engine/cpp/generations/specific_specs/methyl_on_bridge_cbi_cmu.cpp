#include "methyl_on_bridge_cbi_cmu.h"
#include "../handbook.h"

void MethylOnBridgeCBiCMu::find(MethylOnBridge *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(1) };

    if (anchors[0]->is(25) && anchors[1]->is(7))
    {
        if (!anchors[0]->hasRole(25, METHYL_ON_BRIDGE_CBi_CMu) && !anchors[1]->hasRole(7, METHYL_ON_BRIDGE_CBi_CMu))
        {
            auto spec = new MethylOnBridgeCBiCMu(METHYL_ON_BRIDGE_CBi_CMu, parent);

#ifdef PRINT
            spec->wasFound();
#endif // PRINT

            anchors[0]->describe(25, spec);
            anchors[1]->describe(7, spec);

            spec->findChildren();
        }
    }
    else
    {
        if (anchors[0]->hasRole(25, METHYL_ON_BRIDGE_CBi_CMu) && anchors[1]->hasRole(7, METHYL_ON_BRIDGE_CBi_CMu))
        {
            auto spec = anchors[0]->specificSpecByRole(25, METHYL_ON_BRIDGE_CBi_CMu);
            spec->removeReactions();

#ifdef PRINT
            spec->wasForgotten();
#endif // PRINT

            anchors[0]->forget(25, spec);
            anchors[1]->forget(7, spec);
            Handbook::scavenger.markSpec<METHYL_ON_DIMER_CLs_CMu>(spec);
        }
    }
}

void MethylOnBridgeCBiCMu::findChildren()
{
}
