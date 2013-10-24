#include "bridge_cts.h"
#include "../handbook.h"
#include "../reactions/typical/dimer_formation.h"

void BridgeCts::find(BaseSpec *parent)
{
    Atom *anchor = parent->atom(0);

    if (anchor->is(28))
    {
        if (!anchor->prevIs(28))
        {
            BaseSpec *parents[1] = { parent };
            auto bridgeCts = std::shared_ptr<BaseSpec>(new BridgeCts(BRIDGE_CTs, parents));
            anchor->describe(28, bridgeCts);

            Handbook::keeper().store<BRIDGE_CTs>(bridgeCts.get());
        }
    }
    else
    {
        if (anchor->hasRole(28, BRIDGE_CTs))
        {
            auto bridgeCts = dynamic_cast<ReactionsMixin *>(anchor->specByRole(28, BRIDGE_CTs));
            bridgeCts->removeReactions(); // TODO: potencial race condition
            anchor->forget(28, BRIDGE_CTs);
        }
    }
}

void BridgeCts::findChildren()
{
    DimerFormation::find(this);
}
