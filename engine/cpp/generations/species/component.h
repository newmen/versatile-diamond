#ifndef COMPONENT_H
#define COMPONENT_H

#include "../../species/component_spec.h"
using namespace vd;

#include "../handbook.h"

// TODO: B is Base everytime?
template <class B>
class Component : public B, public ComponentSpec
{
public:

    void store() override;

protected:
    template <class... Args>
    Component(Args... args) : B(args...) {}
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B>
void Component<B>::store()
{
    B::store();
    Handbook::componentKeeper().store(this);
}

#endif // COMPONENT_H
