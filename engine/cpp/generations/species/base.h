#ifndef BASE_H
#define BASE_H

#include "../../species/spec_class_builder.h"
#include "../../species/base_spec.h"
#include "../../species/source_spec.h"
#include "../../species/dependent_spec.h"
#include "../../species/parent_spec.h"
#include "../../species/specific_spec.h"
#include "../../species/lateral_spec.h"
#include "../../species/additional_atoms_wrapper.h"
#include "../../species/atom_shift_wrapper.h"
#include "../../species/atoms_swap_wrapper.h"
#include "../../tools/typed.h"
using namespace vd;

#include "../phases/diamond_atoms_iterator.h"
#include "../handbook.h"

template <class B, ushort ST, ushort USED_ATOMS_NUM>
class Base : public Typed<B, ST>, public DiamondAtomsIterator
{
    typedef Typed<B, ST> ParentType;

protected:
    template <class... Args>
    Base(Args... args) : ParentType(args...) {}

public:
    void store() override;
    void remove() override;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Base<B, ST, USED_ATOMS_NUM>::store()
{
    ushort *idxs = this->indexes();
    ushort *rls = this->roles();

    for (uint i = 0; i < USED_ATOMS_NUM; ++i)
    {
        this->atom(idxs[i])->describe(rls[i], this);
    }

    ParentType::store();
}

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Base<B, ST, USED_ATOMS_NUM>::remove()
{
    ParentType::remove();

    ushort *idxs = this->indexes();
    ushort *rls = this->roles();

    for (uint i = 0; i < USED_ATOMS_NUM; ++i)
    {
        this->atom(idxs[i])->forget(rls[i], this);
    }

    Handbook::scavenger().markSpec(this);
}

#endif // BASE_H
