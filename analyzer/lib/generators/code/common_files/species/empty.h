#ifndef EMPTY_H
#define EMPTY_H

#include <species/atoms_swap_wrapper.h>
#include <species/parents_swap_wrapper.h>
#include <species/parents_swap_proxy.h>
#include <species/child_spec.h>
using namespace vd;

#include "overall.h"

template <ushort ST>
class Empty : public Overall<ChildSpec<ParentSpec>, ST>
{
    typedef Overall<ChildSpec<ParentSpec>, ST> ParentType;

public:
    Atom *anchor() const override { return this->parent()->anchor(); }

    void remove() override;

protected:
    template <class... Args> Empty(Args... args) : ParentType(args...) {}

    void findAllChildren() override {}
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort ST>
void Empty<ST>::remove()
{
    if (this->isMarked()) return;
    ParentType::remove();
}

#endif // EMPTY_H
