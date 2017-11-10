#ifndef EMPTY_H
#define EMPTY_H

#include <species/atoms_swap_wrapper.h>
#include <species/parents_swap_wrapper.h>
#include <species/parents_swap_proxy.h>
#include <species/child_spec.h>
using namespace vd;

#include "overall.h"

template <ushort ST>
class EmptyBase : public Overall<ChildSpec<ParentSpec>, ST>
{
    typedef Overall<ChildSpec<ParentSpec>, ST> ParentType;

public:
    typedef EmptyBase<ST> SymmetricType;

    void remove() override;

protected:
    template <class... Args> EmptyBase(Args... args) : ParentType(args...) {}

    void findAllChildren() final {}
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort ST>
void EmptyBase<ST>::remove()
{
    if (this->isMarked()) return;
    ParentType::remove();
}

#endif // EMPTY_H
