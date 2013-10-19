#include "bridge_cts.h"
#include "../handbook.h"

void BridgeCts::find(BaseSpec *parent)
{
    Atom *anchor = parent->atom(0);
    if (!anchor->is(1)) return;
    if (!anchor->prevIs(1))
    {
        BaseSpec *parents[1] = { parent };
        auto bridgeCts = std::shared_ptr<BaseSpec>(new BridgeCts(BRIDGE_CTs, parents));
        anchor->describe(1, bridgeCts);

        bridgeCts->findChildren();
    }
}

void BridgeCts::findChildren()
{
//    DimerFormation::find(this);
}
