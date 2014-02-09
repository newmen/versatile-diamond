#ifndef NEAR_METHYL_ON_BRIDGE_CBI_H
#define NEAR_METHYL_ON_BRIDGE_CBI_H

#include "../../../species/specific/methyl_on_bridge_cbi_cmiu.h"
#include "near_methyl_on_bridge.h"

class NearMethylOnBridgeCBi : public NearMethylOnBridge
{
public:
    template <class S, class L> static void look(ushort methylAtomType, Atom **atoms, const L &lambda);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class S, class L>
void NearMethylOnBridgeCBi::look(ushort methylAtomType, Atom **atoms, const L &lambda)
{
    NearMethylOnBridge::look<MethylOnBridgeCBiCMiu>(7, atoms, [methylAtomType, lambda](Atom *methyl) {
        if (methyl->is(methylAtomType))
        {
            auto target = methyl->specByRole<S>(methylAtomType);
            assert(target);

            lambda(target);
        }
    });
}

#endif // NEAR_METHYL_ON_BRIDGE_CBI_H
