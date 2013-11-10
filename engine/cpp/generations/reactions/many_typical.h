#ifndef MANY_TYPICAL_H
#define MANY_TYPICAL_H

#include <functional>
#include "../../reactions/few_specs_reaction.h"
using namespace vd;

#include "../handbook.h"

template <ushort RT, ushort SCA_RT, ushort TARGETS_NUM>
class ManyTypical : public FewSpecsReaction<TARGETS_NUM>
{
    typedef DiamondRelations::TN (*RelationFunc)(const Diamond *, const Atom *);

public:
    template <class R, ushort ATOMS_NUM>
    static void find(SpecificSpec *target, const ushort *indexes, const ushort *types,
                     ushort otherAtomType, ushort otherSpecType, RelationFunc nLambda);

//    using FewSpecsReaction::FewSpecsReaction;
    ManyTypical(SpecificSpec **targets) : FewSpecsReaction<TARGETS_NUM>(targets) {}

    void store() override;

protected:
    void remove() override;

    static DiamondRelations::TN front100Lambda(const Diamond *diamond, const Atom *anchor);
};

template <ushort RT, ushort SCA_RT, ushort TARGETS_NUM>
template <class R, ushort ATOMS_NUM>
void ManyTypical<RT, SCA_RT, TARGETS_NUM>::find(SpecificSpec *target, const ushort *indexes, const ushort *types,
                                                ushort otherAtomType, ushort otherSpecType, RelationFunc nLambda)
{
    Atom *firstAnchor = target->atom(indexes[0]);

    bool result = false;
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        Atom *anchor = target->atom(indexes[i]);
        assert(anchor->is(types[i]));

        result = result || !anchor->prevIs(types[i]);
    }

    assert(firstAnchor->lattice());
    auto diamond = static_cast<const Diamond *>(firstAnchor->lattice()->crystal());

    auto nbrs = nLambda(diamond, firstAnchor);
    // TODO: maybe need to parallel it?
    if ((result && nbrs[0]) || (nbrs[0] && !nbrs[0]->prevIs(otherAtomType)))
    {
        FewSpecsReaction<TARGETS_NUM>::template addIfHasNeighbour<R>(target, nbrs[0], otherAtomType, otherSpecType);
    }
    bool hasAnother = nbrs[1] && nbrs[1]->isVisited();
    if ((result && hasAnother) || (hasAnother && !nbrs[1]->prevIs(otherAtomType)))
    {
        FewSpecsReaction<TARGETS_NUM>::template addIfHasNeighbour<R>(target, nbrs[1], otherAtomType, otherSpecType);
    }
}

template <ushort RT, ushort SCA_RT, ushort TARGETS_NUM>
void ManyTypical<RT, SCA_RT, TARGETS_NUM>::store()
{
    Handbook::mc().add<RT>(this);
}

template <ushort RT, ushort SCA_RT, ushort TARGETS_NUM>
void ManyTypical<RT, SCA_RT, TARGETS_NUM>::remove()
{
    Handbook::mc().remove<RT>(this, false);
    Handbook::scavenger().markReaction<SCA_RT>(this);
}

template <ushort RT, ushort SCA_RT, ushort TARGETS_NUM>
DiamondRelations::TN ManyTypical<RT, SCA_RT, TARGETS_NUM>::front100Lambda(
        const Diamond *diamond, const Atom *anchor)
{
    return diamond->front_100(anchor);
}

#endif // MANY_TYPICAL_H
