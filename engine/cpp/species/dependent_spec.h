#ifndef DEPENDENT_SPEC_H
#define DEPENDENT_SPEC_H

#include "base_spec.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

template <ushort PARENTS_NUM>
class DependentSpec : public BaseSpec
{
    BaseSpec *_parents[PARENTS_NUM];

protected:
    DependentSpec(BaseSpec **parents);

public:
    ushort size() const;
    Atom *atom(ushort index) const;

    void store() override;
    void remove() override;

    Atom *firstLatticedAtomIfExist() override;

#ifdef PRINT
    void info() override;
    void eachAtom(const std::function<void (Atom *)> &lambda) override;
#endif // PRINT

};

template <ushort PARENTS_NUM>
DependentSpec<PARENTS_NUM>::DependentSpec(BaseSpec **parents)
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        _parents[i] = parents[i];
    }
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
ushort DependentSpec<PARENTS_NUM>::size() const
{
    ushort sum = 0;
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        sum += _parents[i]->size();
    }
    return sum;
}

#ifdef PRINT
template <ushort PARENTS_NUM>
void DependentSpec<PARENTS_NUM>::info()
{
    debugPrintWoLock([&](std::ostream &os) {
        os << name() << " at [" << this << "]";
        for (int i = 0; i < PARENTS_NUM; ++i)
        {
            os << " -> (";
            _parents[i]->info();
            os << ")";
        }
    }, false);
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

    BaseSpec::remove();
}

template <ushort PARENTS_NUM>
Atom *DependentSpec<PARENTS_NUM>::firstLatticedAtomIfExist()
{
    Atom *first = _parents[0]->firstLatticedAtomIfExist();
    if (first->lattice()) return first;

    for (int i = 1; i < PARENTS_NUM; ++i)
    {
        Atom *atom = _parents[i]->firstLatticedAtomIfExist();
        if (atom->lattice()) return atom;
    }

    return first;
}

}

#endif // DEPENDENT_SPEC_H
