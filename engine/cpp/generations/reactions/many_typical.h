#ifndef MANY_TYPICAL_H
#define MANY_TYPICAL_H

#include <functional>
#include "../../reactions/few_specs_reaction.h"
using namespace vd;

#include "typical.h"

template <ushort RT, ushort TARGETS_NUM>
class ManyTypical : public Typical<FewSpecsReaction<TARGETS_NUM>, RT>
{
    typedef DiamondRelations::TN (*RelationFunc)(const Diamond *, const Atom *);

protected:
    template <class R>
    static void find(SpecificSpec *target, const ushort *indexes, const ushort *types, ushort atomsNum,
                     ushort otherAtomType, ushort otherSpecType, RelationFunc nLambda);

//    using Typical<FewSpecsReaction<TARGETS_NUM>, RT>::Typical;
    ManyTypical(SpecificSpec **targets) : Typical<FewSpecsReaction<TARGETS_NUM>, RT>(targets) {}

    static DiamondRelations::TN front100Lambda(const Diamond *diamond, const Atom *anchor);
};

template <ushort RT, ushort TARGETS_NUM>
template <class R>
void ManyTypical<RT, TARGETS_NUM>::find(SpecificSpec *target, const ushort *indexes, const ushort *types, ushort atomsNum,
                                        ushort otherAtomType, ushort otherSpecType, RelationFunc nLambda)
{
    bool targetIsValid = Typical<FewSpecsReaction<TARGETS_NUM>, RT>::find(target, indexes, types, atomsNum);
    Atom *firstAnchor = target->atom(indexes[0]);

    assert(firstAnchor->lattice());
    auto diamond = static_cast<const Diamond *>(firstAnchor->lattice()->crystal());

    auto nbrs = nLambda(diamond, firstAnchor);
    if ((targetIsValid && nbrs[0]) || (nbrs[0] && !nbrs[0]->prevIs(otherAtomType)))
    {
        FewSpecsReaction<TARGETS_NUM>::template addIfHasNeighbour<R>(target, nbrs[0], otherAtomType, otherSpecType);
    }
    bool hasAnother = nbrs[1] && nbrs[1]->isVisited();
    if ((targetIsValid && hasAnother) || (hasAnother && !nbrs[1]->prevIs(otherAtomType)))
    {
        FewSpecsReaction<TARGETS_NUM>::template addIfHasNeighbour<R>(target, nbrs[1], otherAtomType, otherSpecType);
    }
}

template <ushort RT, ushort TARGETS_NUM>
DiamondRelations::TN ManyTypical<RT, TARGETS_NUM>::front100Lambda(
        const Diamond *diamond, const Atom *anchor)
{
    return diamond->front_100(anchor);
}

#endif // MANY_TYPICAL_H
