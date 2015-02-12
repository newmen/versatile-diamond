#ifndef MULTI_LATERAL_REACTION_H
#define MULTI_LATERAL_REACTION_H

#include "single_lateral_reaction.h"

namespace vd
{

template <ushort LATERAL_REACTIONS_NUM>
class MultiLateralReaction : public LateralReaction
{
    SingleLateralReaction *_chunks[LATERAL_REACTIONS_NUM];

public:
#ifdef PRINT
    void info(std::ostream &os);
#endif // PRINT

protected:
    MultiLateralReaction(SingleLateralReaction **chunks);

    void insertToTargets(LateralReaction *reaction);
    void eraseFromTargets(LateralReaction *reaction);

    template <class L> void eachChunk(const L &lambda);
};


//////////////////////////////////////////////////////////////////////////////////////

template <ushort LATERAL_REACTIONS_NUM>
MultiLateralReaction<LATERAL_REACTIONS_NUM>::MultiLateralReaction(SingleLateralReaction **chunks) :
    LateralReaction(chunks[0]->parent())
{
    static_assert(LATERAL_REACTIONS_NUM > 1, "Wrong number of internal lateral reactions");
    for (uint i = 0; i < LATERAL_REACTIONS_NUM; ++i)
    {
        assert(chunks[i]);
        _chunks[i] = chunks[i];
    }
}

template <ushort LATERAL_REACTIONS_NUM>
void MultiLateralReaction<LATERAL_REACTIONS_NUM>::insertToTargets(LateralReaction *reaction)
{
    insertToParentTargets();
    for (uint i = 0; i < LATERAL_REACTIONS_NUM; ++i)
    {
        _chunks[i]->insertToLateralTargets(reaction);
    }
}

template <ushort LATERAL_REACTIONS_NUM>
void MultiLateralReaction<LATERAL_REACTIONS_NUM>::eraseFromTargets(LateralReaction *reaction)
{
    for (uint i = 0; i < LATERAL_REACTIONS_NUM; ++i)
    {
        _chunks[i]->eraseFromLateralTargets(reaction);
    }
    eraseFromParentTargets();
}

template <ushort LATERAL_REACTIONS_NUM>
template <class L>
void MultiLateralReaction<LATERAL_REACTIONS_NUM>::eachChunk(const L &lambda)
{
    for (uint i = 0; i < LATERAL_REACTIONS_NUM; ++i)
    {
        lambda(_chunks[i]);
    }
}

#ifdef PRINT
template <ushort LATERAL_REACTIONS_NUM>
void ConcreteLateralReaction<LATERAL_REACTIONS_NUM>::info(std::ostream &os)
{
    os << "Multi-Lateral reaction " << this->name() << " [" << this << "]:";
    for (uint i = 0; i < LATERAL_REACTIONS_NUM; ++i)
    {
        os << "\n  => ";
        _chunks[i]->info(os);
    }
    os << std::endl;
}
#endif // PRINT

}

#endif // MULTI_LATERAL_REACTION_H
