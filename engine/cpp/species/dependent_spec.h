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
//    static BaseSpec *checkAndFind(Atom *anchor, ushort rType, ushort sType);

    DependentSpec(BaseSpec **parents);

public:
    ushort size() const;
    Atom *atom(ushort index) const;
    void eachAtom(const std::function<void (Atom *)> &lambda) override;

    void store() override;
    void remove() override;

#ifdef PRINT
    void info() override;
#endif // PRINT

};

//template <ushort PARENTS_NUM>
//BaseSpec *DependentSpec<PARENTS_NUM>::checkAndFind(Atom *anchor, ushort rType, ushort sType)
//{
//    if (PARENTS_NUM == 1)
//    {
//        return BaseSpec::checkAndFind(anchor, rType, sType);
//    }
//    else
//    {
//        auto spec = anchor->specByRole(rType, sType);
//        if (spec)
//        {
//            if (!spec->isVisited() && spec->anchor() == anchor)
////            if (!spec->isVisited())
//            {
//                spec->callFindChildren();
//            }
//        }

//        return spec;
//    }
//}

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

}

#endif // DEPENDENT_SPEC_H
