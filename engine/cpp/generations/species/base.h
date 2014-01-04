#ifndef BASE_H
#define BASE_H

#include "../../species/source_spec.h"
#include "../../species/specific_spec.h"
#include "../../species/lateral_spec.h"
#include "../../species/component_spec.h"
#include "../../species/additional_atoms_wrapper.h"
#include "../../species/atom_shift_wrapper.h"
#include "../../species/atoms_swap_wrapper.h"
using namespace vd;

#include "overall.h"

template <class B, ushort ST, ushort USED_ATOMS_NUM>
class Base : public Overall<B, ST>
{
    typedef Overall<B, ST> ParentType;

public:
    Atom *anchor() override { return this->atom(indexes()[0]); }

    void store() override;
    void remove() override;

protected:
    template <class... Args>
    Base(Args... args) : ParentType(args...) {}

    virtual const ushort *indexes() const = 0;
    virtual const ushort *roles() const = 0;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Base<B, ST, USED_ATOMS_NUM>::store()
{
    const ushort *idxs = this->indexes();
    const ushort *rls = this->roles();

    for (uint i = 0; i < USED_ATOMS_NUM; ++i)
    {
        this->atom(idxs[i])->describe(rls[i], this);
    }

    ParentType::store();
}

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Base<B, ST, USED_ATOMS_NUM>::remove()
{
    const ushort *idxs = this->indexes();
    const ushort *rls = this->roles();

    for (uint i = 0; i < USED_ATOMS_NUM; ++i)
    {
        this->atom(idxs[i])->forget(rls[i], this);
    }

    ParentType::remove();
}

#endif // BASE_H
