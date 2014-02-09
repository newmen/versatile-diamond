#ifndef NEAR_METHYL_ON_DIMER_H
#define NEAR_METHYL_ON_DIMER_H

#include "../../../species/specific/methyl_on_dimer_cmsiu.h"
#include "near_methyl_on_bridge.h"

class NearMethylOnDimer : public NearMethylOnBridge
{
public:
    template <class S, class L> static void look(ushort methylAtomType, Atom **atoms, const L &lambda);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class S, class L>
void NearMethylOnDimer::look(ushort methylAtomType, Atom **atoms, const L &lambda)
{
    NearMethylOnBridge::look<MethylOnDimerCMsiu>(23, atoms, [methylAtomType, lambda](Atom *methyl) {
        if (methyl->is(methylAtomType))
        {
            auto target = methyl->specByRole<S>(methylAtomType);
            assert(target);

            lambda(target);
        }
    });
}

#endif // NEAR_METHYL_ON_DIMER_H
