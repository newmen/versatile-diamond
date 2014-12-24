#ifndef LATERABLE_ROLE_H
#define LATERABLE_ROLE_H

#include "concretizable_role.h"

template <template <ushort RT, ushort TARGETS_NUM> class Wrapper, ushort RT, ushort TARGETS_NUM>
class LaterableRole;

template <ushort RT, ushort TARGETS_NUM>
class LaterableRole<Typical, RT, TARGETS_NUM> : public ConcretizableRole<Typical, RT, TARGETS_NUM>
{
    typedef ConcretizableRole<Typical, RT, TARGETS_NUM> ParentType;

public:
    void store() override;

protected:
    template <class... Args> LaterableRole(Args... args)  : ParentType(args...) {}

    virtual LateralReaction *lookAround() = 0;
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort RT, ushort TARGETS_NUM>
void LaterableRole<Typical, RT, TARGETS_NUM>::store()
{
    auto lateralReaction = lookAround();
    if (lateralReaction)
    {
        lateralReaction->store();
    }
    else
    {
        ParentType::store();
    }
}

#endif // LATERABLE_ROLE_H
