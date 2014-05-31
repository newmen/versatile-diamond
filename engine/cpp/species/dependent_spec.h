#ifndef DEPENDENT_SPEC_H
#define DEPENDENT_SPEC_H

#include "parent_spec.h"

namespace vd
{

template <class B, ushort PARENTS_NUM = 1>
class DependentSpec : public B
{
    ParentSpec *_parents[PARENTS_NUM];

protected:
    DependentSpec(ParentSpec *parent);
    DependentSpec(ParentSpec **parents);

    ParentSpec *parent(ushort index) const;

public:
    ushort size() const;
    Atom *atom(ushort index) const;

    void store() override;
    void remove() override;

#ifdef PRINT
    void info(std::ostream &os) override;
    void eachAtom(const std::function<void (Atom *)> &lambda) override;
#endif // PRINT
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort PARENTS_NUM>
DependentSpec<B, PARENTS_NUM>::DependentSpec(ParentSpec *parent) : DependentSpec<B, PARENTS_NUM>(&parent)
{
    static_assert(PARENTS_NUM == 1, "Wrong initializing of DependentSpec with many parents by just one");
}

template <class B, ushort PARENTS_NUM>
DependentSpec<B, PARENTS_NUM>::DependentSpec(ParentSpec **parents)
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        assert(parents[i]);
        _parents[i] = parents[i];
    }
}

template <class B, ushort PARENTS_NUM>
ParentSpec *DependentSpec<B, PARENTS_NUM>::parent(ushort index) const
{
    assert(index < PARENTS_NUM);
    return _parents[index];
}

template <class B, ushort PARENTS_NUM>
ushort DependentSpec<B, PARENTS_NUM>::size() const
{
    ushort sum = 0;
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        sum += _parents[i]->size();
    }
    return sum;
}

template <class B, ushort PARENTS_NUM>
Atom *DependentSpec<B, PARENTS_NUM>::atom(ushort index) const
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

template <class B, ushort PARENTS_NUM>
void DependentSpec<B, PARENTS_NUM>::store()
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        _parents[i]->insertChild(this);
    }

    B::store();
}

template <class B, ushort PARENTS_NUM>
void DependentSpec<B, PARENTS_NUM>::remove()
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        _parents[i]->eraseChild(this);
    }

    B::remove();
}

#ifdef PRINT
template <class B, ushort PARENTS_NUM>
void DependentSpec<B, PARENTS_NUM>::info(std::ostream &os)
{
    os << this->name() << " at [" << this << "]";
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        os << " -> (";
        _parents[i]->info(os);
        os << ")";
    }
}

template <class B, ushort PARENTS_NUM>
void DependentSpec<B, PARENTS_NUM>::eachAtom(const std::function<void (Atom *)> &lambda)
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        _parents[i]->eachAtom(lambda);
    }
}
#endif // PRINT

}

#endif // DEPENDENT_SPEC_H
