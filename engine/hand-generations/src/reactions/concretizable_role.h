#ifndef CONCRETIZABLE_ROLE_H
#define CONCRETIZABLE_ROLE_H

#include "central.h"
#include "single_lateral.h"
#include "multi_lateral.h"

template<template <ushort RT, ushort TARGETS_NUM> class Wrapper, ushort RT, ushort TARGETS_NUM>
class ConcretizableRole;

//////////////////////////////////////////////////////////////////////////////////////

template <ushort RT, ushort TARGETS_NUM>
class ConcretizableRole<Central, RT, TARGETS_NUM> : public Central<RT, TARGETS_NUM>
{
public:
    void concretize(SingleLateralReaction *chunk);

protected:
    template <class... Args> ConcretizableRole(Args... args) : Central<RT, TARGETS_NUM>(args...) {}
};

// ------------------------------------------------------------------------------------------------------------------ //

template <ushort RT, ushort TARGETS_NUM>
void ConcretizableRole<Central, RT, TARGETS_NUM>::concretize(SingleLateralReaction *chunk)
{
    this->CentralReaction::remove();
    chunk->store();
}

//////////////////////////////////////////////////////////////////////////////////////

template <ushort RT, ushort LATERALS_NUM>
class ConcretizableRole<SingleLateral, RT, LATERALS_NUM> : public SingleLateral<RT, LATERALS_NUM>
{
public:
    void concretize(SingleLateralReaction *chunk);

protected:
    template <class... Args> ConcretizableRole(Args... args) : SingleLateral<RT, LATERALS_NUM>(args...) {}
};

// ------------------------------------------------------------------------------------------------------------------ //

template <ushort RT, ushort LATERALS_NUM>
void ConcretizableRole<SingleLateral, RT, LATERALS_NUM>::concretize(SingleLateralReaction *chunk)
{
    this->LateralReaction::remove();

    SingleLateralReaction *chunks[2] = { chunk, this };
    this->parent()->selectFrom(chunks, 2)->store();
}

//////////////////////////////////////////////////////////////////////////////////////

template <ushort RT, ushort LATERAL_REACTIONS_NUM>
class ConcretizableRole<MultiLateral, RT, LATERAL_REACTIONS_NUM> : public MultiLateral<RT, LATERAL_REACTIONS_NUM>
{
public:
    void concretize(SingleLateralReaction *chunk);

protected:
    template <class... Args> ConcretizableRole(Args... args) : MultiLateral<RT, LATERAL_REACTIONS_NUM>(args...) {}
};

// ------------------------------------------------------------------------------------------------------------------ //

template <ushort RT, ushort LATERAL_REACTIONS_NUM>
void ConcretizableRole<MultiLateral, RT, LATERAL_REACTIONS_NUM>::concretize(SingleLateralReaction *chunk)
{
    this->LateralReaction::remove();
    Handbook::scavenger().markReaction(this);

    ushort index = 1;
    SingleLateralReaction *chunks[LATERAL_REACTIONS_NUM + 1] = { chunk };
    this->eachChunks([&chunks, &index](SingleLateralReaction *innerChunk) {
        chunks[index++] = innerChunk;
    });

    this->parent()->selectFrom(chunks, index)->store();
}

#endif // CONCRETIZABLE_ROLE_H
