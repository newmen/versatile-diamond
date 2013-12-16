#ifndef CONCRETIZABLE_ROLE_H
#define CONCRETIZABLE_ROLE_H

#include "typical.h"
#include "lateral.h"

template<template <ushort RT, ushort TARGETS_NUM> class Wrapper, ushort RT, ushort TARGETS_NUM> class ConcretizableRole;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <ushort RT, ushort TARGETS_NUM>
class ConcretizableRole<Typical, RT, TARGETS_NUM> : public Typical<RT, TARGETS_NUM>
{
public:
    template <class R> void
    concretize(LateralSpec *spec);

protected:
    template <class... Args>
    ConcretizableRole(Args... args) : Typical<RT, TARGETS_NUM>(args...) {}
};

template <ushort RT, ushort TARGETS_NUM>
template <class R>
void ConcretizableRole<Typical, RT, TARGETS_NUM>::concretize(LateralSpec *spec)
{
    Handbook::mc().remove(RT, this);
    this->eraseFromTargets(this);

    Creator::createBy<R>(this, spec);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <ushort RT, ushort LATERALS_NUM>
class ConcretizableRole<Lateral, RT, LATERALS_NUM> : public Lateral<RT, LATERALS_NUM>
{
public:
    template <class R> void
    concretize(LateralSpec *spec);

protected:
    template <class... Args>
    ConcretizableRole(Args... args) : Lateral<RT, LATERALS_NUM>(args...) {}
};

template <ushort RT, ushort LATERALS_NUM>
template <class R>
void ConcretizableRole<Lateral, RT, LATERALS_NUM>::concretize(LateralSpec *spec)
{
    Handbook::mc().remove(RT, this);
    this->eraseFromTargets(this);
    Handbook::scavenger().markReaction(this);

    Creator::createBy<R>(this, spec);
}

#endif // CONCRETIZABLE_ROLE_H
