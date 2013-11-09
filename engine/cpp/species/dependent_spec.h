#ifndef DEPENDENT_SPEC_H
#define DEPENDENT_SPEC_H

#include "base_spec.h"

#ifdef PRINT
#include <iostream>
#endif // PRINT

namespace vd
{

template <ushort PARENTS_NUM>
class DependentSpec : public BaseSpec
{
    BaseSpec *_parents[PARENTS_NUM];

protected:
    DependentSpec(ushort type, BaseSpec **parents);

public:
    ushort size() const;
    Atom *atom(ushort index);
    void eachAtom(const std::function<void (Atom *)> &lambda) override;

#ifdef PRINT
    void info() override;
#endif // PRINT

protected:
    BaseSpec *parent(ushort index = 0);
    const BaseSpec *parent(ushort index = 0) const;
};

template <ushort PARENTS_NUM>
DependentSpec<PARENTS_NUM>::DependentSpec(ushort type, BaseSpec **parents) : BaseSpec(type)
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        _parents[i] = parents[i];
    }
}

template <ushort PARENTS_NUM>
Atom *DependentSpec<PARENTS_NUM>::atom(ushort index)
{
    assert(index < size());

    int i = 0;
    while (index >= parent(i)->size())
    {
        index -= parent(i)->size();
        ++i;
    }
    return parent(i)->atom(index);
}

template <ushort PARENTS_NUM>
ushort DependentSpec<PARENTS_NUM>::size() const
{
    ushort sum = 0;
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        sum += parent(i)->size();
    }
    return sum;
}

#ifdef PRINT
template <ushort PARENTS_NUM>
void DependentSpec<PARENTS_NUM>::info()
{
    std::cout << name() << " at [" << this << "]";
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        std::cout << " -> (";
        _parents[i]->info();
        std::cout << ")";
    }
}
#endif // PRINT

template <ushort PARENTS_NUM>
void DependentSpec<PARENTS_NUM>::eachAtom(const std::function<void (Atom *)> &lambda)
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        _parents[i]->eachAtom(lambda);
    }
}

template <ushort PARENTS_NUM>
BaseSpec *DependentSpec<PARENTS_NUM>::parent(ushort index)
{
    return _parents[index];
}

template <ushort PARENTS_NUM>
const BaseSpec *DependentSpec<PARENTS_NUM>::parent(ushort index) const
{
    return _parents[index];
}

}

#endif // DEPENDENT_SPEC_H
