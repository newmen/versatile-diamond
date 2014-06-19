#ifndef NEAR_HIGH_BRIDGE_H
#define NEAR_HIGH_BRIDGE_H

#include "../../../species/specific/high_bridge.h"
#include "near_methyl_on_bridge.h"

class NearHighBridge : public NearMethylOnBridge
{
public:
    template <class S, class L> static void look(ushort amorphAtomType, Atom **atoms, const L &lambda);
};

//////////////////////////////////////////////////////////////////////////////////////

template <class S, class L>
void NearHighBridge::look(ushort amorphAtomType, Atom **atoms, const L &lambda)
{
    NearMethylOnBridge::look<HighBridge>(19, atoms, [amorphAtomType, lambda](Atom *amorph) {
        if (amorph->is(amorphAtomType))
        {
            auto target = amorph->specByRole<S>(amorphAtomType);
            assert(target);

            lambda(target);
        }
    });
}

#endif // NEAR_HIGH_BRIDGE_H
