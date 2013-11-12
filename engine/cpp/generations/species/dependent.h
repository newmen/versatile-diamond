#ifndef DEPENDENT_H
#define DEPENDENT_H

#include "../../species/dependent_spec.h"
using namespace vd;

#include "base.h"

template <ushort ST, ushort USED_ATOMS_NUM, class B = DependentSpec<USED_ATOMS_NUM>>
class Dependent : public Base<B, ST, USED_ATOMS_NUM>
{
protected:
//    using Base<B, ST, USED_ATOMS_NUM>::Base;
    template <class... Args>
    Dependent(Args... args) : Base<B, ST, USED_ATOMS_NUM>(args...) {}

public:
    void store() override;
};

template <ushort ST, ushort USED_ATOMS_NUM, class B>
void Dependent<ST, USED_ATOMS_NUM, B>::store()
{
    B::store();
    Base<B, ST, USED_ATOMS_NUM>::store();
}

#endif // DEPENDENT_H
