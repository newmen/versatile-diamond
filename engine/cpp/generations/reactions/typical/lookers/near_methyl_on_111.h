#ifndef NEAR_METHYL_ON_111_H
#define NEAR_METHYL_ON_111_H

#include "../../../species/specific/methyl_on_111_cmiu.h"
#include "near_methyl_on_bridge.h"

class NearMethylOn111 : public NearMethylOnBridge
{
public:
    template <class S, class L> static void look(ushort methylAtomType, Atom **atoms, const L &lambda);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class S, class L>
void NearMethylOn111::look(ushort methylAtomType, Atom **atoms, const L &lambda)
{
    NearMethylOnBridge::look<MethylOn111CMiu>(33, atoms, [methylAtomType, lambda](Atom *methyl) {
        if (methyl->is(methylAtomType))
        {
            auto target = methyl->specByRole<S>(methylAtomType);
            assert(target);

            lambda(target);
        }
    });
}

#endif // NEAR_METHYL_ON_111_H
