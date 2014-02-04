#ifndef COMPONENT_H
#define COMPONENT_H

#include "../../species/component_spec.h"
using namespace vd;

#include "../handbook.h"

template <class B>
class Component : public B, public ComponentSpec
{
    typedef B ParentType;

public:
    void store() override;

protected:
    template <class... Args>
    Component(Args... args);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B>
template <class... Args>
Component<B>::Component(Args... args) : ParentType(args...)
{
    static_assert(!std::is_base_of<ComponentSpec, B>::value, "Specie already is component");
}

template <class B>
void Component<B>::store()
{
    ParentType::store();
    Handbook::componentKeeper().store(this);
}

#endif // COMPONENT_H
