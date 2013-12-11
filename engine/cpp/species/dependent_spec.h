#ifndef DEPENDENT_SPEC_H
#define DEPENDENT_SPEC_H

#include "parent_spec.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

template <ushort PARENTS_NUM>
class DependentSpec : public ParentSpec
{
    BaseSpec *_parents[PARENTS_NUM];

protected:
    DependentSpec(BaseSpec **parents);

public:
    enum : ushort { UsedAtomsNum = PARENTS_NUM };

    ushort size() const;
    Atom *atom(ushort index) const;

    void store() override;
    void remove() override;

    template <class L>
    void eachParent(const L &lambda);

#ifdef PRINT
    void info(std::ostream &os) override;
    void eachAtom(const std::function<void (Atom *)> &lambda) override;
#endif // PRINT
};

template <ushort PARENTS_NUM>
DependentSpec<PARENTS_NUM>::DependentSpec(BaseSpec **parents)
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        assert(parents[i]);
        _parents[i] = parents[i];
    }
}

template <ushort PARENTS_NUM>
ushort DependentSpec<PARENTS_NUM>::size() const
{
    ushort sum = 0;
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        sum += _parents[i]->size();
    }
    return sum;
}

template <ushort PARENTS_NUM>
Atom *DependentSpec<PARENTS_NUM>::atom(ushort index) const
{
    assert(index < size());

    int i = 0;
    while (index >= _parents[i]->size())
    {
        index -= _parents[i]->size();
        ++i;
    }
    return _parents[i]->atom(index);
}

template <ushort PARENTS_NUM>
void DependentSpec<PARENTS_NUM>::store()
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        _parents[i]->addChild(this);
    }
}

template <ushort PARENTS_NUM>
void DependentSpec<PARENTS_NUM>::remove()
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        _parents[i]->removeChild(this);
    }

    ParentSpec::remove();
}

template <ushort PARENTS_NUM>
template <class L>
void DependentSpec<PARENTS_NUM>::eachParent(const L &lambda)
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        lambda(_parents[i]);
    }
}

#ifdef PRINT
template <ushort PARENTS_NUM>
void DependentSpec<PARENTS_NUM>::info(std::ostream &os)
{
    os << name() << " at [" << this << "]";
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        os << " -> (";
        _parents[i]->info(os);
        os << ")";
    }
}

template <ushort PARENTS_NUM>
void DependentSpec<PARENTS_NUM>::eachAtom(const std::function<void (Atom *)> &lambda)
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        _parents[i]->eachAtom(lambda);
    }
}
#endif // PRINT

}

#endif // DEPENDENT_SPEC_H
