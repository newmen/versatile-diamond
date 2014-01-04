#ifndef OVERALL_H
#define OVERALL_H

#include "../../species/spec_class_builder.h"
#include "../../species/base_spec.h"
#include "../../species/dependent_spec.h"
#include "../../species/parent_spec.h"
#include "../../tools/typed.h"
using namespace vd;

#include "../phases/diamond_atoms_iterator.h"
#include "../handbook.h"

template <class B, ushort ST>
class Overall : public Typed<B, ST>, public DiamondAtomsIterator
{
    typedef Typed<B, ST> ParentType;

public:
    void remove() override;

protected:
    template <class... Args>
    Overall(Args... args) : ParentType(args...) {}
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort ST>
void Overall<B, ST>::remove()
{
    B::remove();
    Handbook::scavenger().markSpec(this);
}

#endif // OVERALL_H
