#ifndef LATERABLE_ROLE_H
#define LATERABLE_ROLE_H

#include "../../species/specific_spec.h"
#include "../../reactions/lateral_reaction.h"
using namespace vd;

#include "concretizable_role.h"

// TODO: move to kernel classes, but dependent from concretizable role
template <class B>
class LaterableRole : public ConcretizableRole<B>
{
    typedef ConcretizableRole<B> ParentType;

public:
    void store() override;

protected:
    template <class... Args>
    LaterableRole(Args... args);

    virtual LateralReaction *findLateral() = 0;
};

template <class B>
template <class... Args>
LaterableRole<B>::LaterableRole(Args... args) : ParentType(args...)
{
    static_assert(!std::is_base_of<LateralReaction, B>::value, "Template argument should not derive LateralReaction");
}

template <class B>
void LaterableRole<B>::store()
{
    auto lateralReaction = findLateral();
    if (lateralReaction)
    {
        lateralReaction->store();
    }
    else
    {
        B::store();
    }
}

#endif // LATERABLE_ROLE_H
