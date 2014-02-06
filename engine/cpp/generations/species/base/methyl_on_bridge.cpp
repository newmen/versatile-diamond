#include "methyl_on_bridge.h"
#include "../../reactions/ubiquitous/local/methyl_on_bridge_activation.h"
#include "../../reactions/ubiquitous/local/methyl_on_bridge_deactivation.h"
#include "../specific/methyl_on_bridge_cbi_cmu.h"
#include "../specific/methyl_on_111_cmu.h"

const ushort MethylOnBridge::__indexes[2] = { 1, 0 };
const ushort MethylOnBridge::__roles[2] = { 9, 14 };

#ifdef PRINT
const char *MethylOnBridge::name() const
{
    static const char value[] = "methyl on bridge";
    return value;
}
#endif // PRINT

void MethylOnBridge::find(Bridge *target)
{
    Atom *anchor = target->atom(0);
    if (anchor->is(9))
    {
        if (!anchor->checkAndFind(METHYL_ON_BRIDGE, 9))
        {
            Atom *amorph = anchor->amorphNeighbour();
            if (amorph->is(14))
            {
                create<MethylOnBridge>(amorph, target);
            }
        }
    }
}

void MethylOnBridge::store()
{
    Base::store();

    Atom *target = this->atom(0);
    if (target->isVisited())
    {
        MethylOnBridgeActivation::concretize(target);
        MethylOnBridgeDeactivation::concretize(target);
    }
}

void MethylOnBridge::remove()
{
    Base::remove();

    Atom *target = this->atom(0);
    if (target->isVisited())
    {
        MethylOnBridgeActivation::unconcretize(target);
        MethylOnBridgeDeactivation::unconcretize(target);
    }
}

void MethylOnBridge::findAllChildren()
{
    MethylOnBridgeCBiCMu::find(this);
    MethylOn111CMu::find(this);
}
