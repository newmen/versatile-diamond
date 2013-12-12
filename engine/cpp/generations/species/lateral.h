#ifndef LATERAL_H
#define LATERAL_H

#include "../../species/concrete_lateral_spec.h"
#include "../../species/removable_reactant.h"
using namespace vd;

#include "base.h"

template <class B>
class Lateral : public Base<RemovableReactant<ConcreteLateralSpec<B>>>
{
    typedef RemovableReactant<ConcreteLateralSpec<B>> WrappingType;
    typedef Base<WrappingType> ParentType;

public:
    template <class... Args>
    Lateral(Args... args) : ParentType(args...) {}

    void store() override;
    void findChildren() override;
};

template <class B>
void Lateral<B>::findChildren()
{
    if (this->isNew())
    {
        Handbook::lateralKeeper().store(this);
    }

    ParentType::findChildren();
}

template <class B>
void Lateral<B>::store()
{
    WrappingType::store();
    ParentType::store();
}

#endif // LATERAL_H
