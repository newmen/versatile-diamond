#ifndef CHILD_SPEC_H
#define CHILD_SPEC_H

#include "parent_spec.h"

namespace vd
{

// Uses for symmetry
template <class B, ushort PARENTS_NUM = 1>
class ChildSpec : public B
{
    ParentSpec *_parents[PARENTS_NUM];

protected:
    ChildSpec(ParentSpec *parent);
    ChildSpec(ParentSpec **parents);

public:
    inline ParentSpec *parent(ushort index = 0) const;

    ushort size() const;
    Atom *atom(ushort index) const override;

    void store() override { assert(false); } // symmetric specie should be created by target specie

#ifdef PRINT
    void info(std::ostream &os) override;
    void eachAtom(const std::function<void (Atom *)> &lambda) override;
#endif // PRINT
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort PARENTS_NUM>
ChildSpec<B, PARENTS_NUM>::ChildSpec(ParentSpec *parent) : ChildSpec<B, PARENTS_NUM>(&parent)
{
    static_assert(PARENTS_NUM == 1, "Wrong initializing of ChildSpec with many parents by just one");
}

template <class B, ushort PARENTS_NUM>
ChildSpec<B, PARENTS_NUM>::ChildSpec(ParentSpec **parents)
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        assert(parents[i]);
        _parents[i] = parents[i];
    }
}

template <class B, ushort PARENTS_NUM>
ParentSpec *ChildSpec<B, PARENTS_NUM>::parent(ushort index) const
{
    assert(index < PARENTS_NUM);
    return _parents[index];
}

template <class B, ushort PARENTS_NUM>
ushort ChildSpec<B, PARENTS_NUM>::size() const
{
    ushort sum = 0;
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        sum += _parents[i]->size();
    }
    return sum;
}

template <class B, ushort PARENTS_NUM>
Atom *ChildSpec<B, PARENTS_NUM>::atom(ushort index) const
{
    assert(index < size());

    int i = 0;
    while (true)
    {
        ushort sz = _parents[i]->size();
        if (index < sz) break;
        index -= sz;
        ++i;
    }
    return _parents[i]->atom(index);
}

#ifdef PRINT
template <class B, ushort PARENTS_NUM>
void ChildSpec<B, PARENTS_NUM>::info(std::ostream &os)
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
void ChildSpec<B, PARENTS_NUM>::eachAtom(const std::function<void (Atom *)> &lambda)
{
    for (int i = 0; i < PARENTS_NUM; ++i)
    {
        _parents[i]->eachAtom(lambda);
    }
}
#endif // PRINT

}

#endif // CHILD_SPEC_H
