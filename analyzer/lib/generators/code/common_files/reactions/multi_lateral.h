#ifndef MULTI_LATERAL_H
#define MULTI_LATERAL_H

#include "lateral.h"

template <ushort RT, ushort LATERAL_REACTIONS_NUM>
class MultiLateral : public Lateral<MultiLateralReaction<LATERAL_REACTIONS_NUM>, RT>
{
    typedef Lateral<MultiLateralReaction<LATERAL_REACTIONS_NUM>, RT> ParentType;

public:
    void remove() override;

protected:
    template <class... Args> MultiLateral(Args... args) : ParentType(args...) {}

    void createUnconcreted(LateralSpec *spec) override;
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort RT, ushort LATERAL_REACTIONS_NUM>
void MultiLateral<RT, LATERAL_REACTIONS_NUM>::remove()
{
    ParentType::remove();
    this->eachChunk([](SingleLateralReaction *chunk) {
        Handbook::scavenger().markReaction(chunk);
    });
}

template <ushort RT, ushort LATERAL_REACTIONS_NUM>
void MultiLateral<RT, LATERAL_REACTIONS_NUM>::createUnconcreted(LateralSpec *spec)
{
    ushort index = 0;
    SingleLateralReaction *rest[LATERAL_REACTIONS_NUM - 1];
    this->eachChunk([&spec, &rest, &index](SingleLateralReaction *chunk) {
        if (chunk->haveTarget(spec))
        {
            Handbook::scavenger().markReaction(chunk);
        }
        else
        {
            rest[index++] = chunk;
        }
    });

    assert(index == LATERAL_REACTIONS_NUM - 1);
    this->parent()->selectFrom(rest, index)->store();
}

#endif // MULTI_LATERAL_H
