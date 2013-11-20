#ifndef MANY_TYPICAL_H
#define MANY_TYPICAL_H

#include <functional>
#include "../../reactions/few_specs_reaction.h"
#include "../../reactions/target_atoms.h"
using namespace vd;

#include "typical.h"

template <ushort RT, ushort TARGETS_NUM>
class ManyTypical : public Typical<FewSpecsReaction<TARGETS_NUM>, RT>
{
    typedef DiamondRelations::TN (*RelationFunc)(const Diamond *, const Atom *);

protected:
    template <class R>
    static void find(const TargetAtoms &ta,
                     ushort otherAtomType, ushort otherSpecType, RelationFunc nLambda);

//    using Typical<FewSpecsReaction<TARGETS_NUM>, RT>::Typical;
    ManyTypical(SpecificSpec **targets) : Typical<FewSpecsReaction<TARGETS_NUM>, RT>(targets) {}

    static DiamondRelations::TN front100Lambda(const Diamond *diamond, const Atom *anchor);
};

template <ushort RT, ushort TARGETS_NUM>
template <class R>
void ManyTypical<RT, TARGETS_NUM>::find(const TargetAtoms &ta,
                                        ushort otherAtomType, ushort otherSpecType, RelationFunc nLambda)
{
//    if (ta.isUpdated()) return;
    Atom *firstAnchor = ta.firstAnchor();

    assert(firstAnchor->lattice());
    auto diamond = static_cast<const Diamond *>(firstAnchor->lattice()->crystal());

    auto nbrs = nLambda(diamond, firstAnchor);
    if (nbrs[0]) //  && !nbrs[0]->prevIs(otherAtomType)
    {
        FewSpecsReaction<TARGETS_NUM>::template addIfHasNeighbour<R>(ta.target(), nbrs[0], otherAtomType, otherSpecType);
    }
    if (nbrs[1] && nbrs[1]->isVisited())
    {
        FewSpecsReaction<TARGETS_NUM>::template addIfHasNeighbour<R>(ta.target(), nbrs[1], otherAtomType, otherSpecType);
    }
}

template <ushort RT, ushort TARGETS_NUM>
DiamondRelations::TN ManyTypical<RT, TARGETS_NUM>::front100Lambda(
        const Diamond *diamond, const Atom *anchor)
{
    return diamond->front_100(anchor);
}

#endif // MANY_TYPICAL_H
