#ifndef EMPTY_SIDEPIECE_H
#define EMPTY_SIDEPIECE_H

#include "empty_base.h"
#include "sidepiece.h"

template <ushort ST>
class EmptySidepiece : public Sidepiece<EmptyBase<ST>>
{
    typedef Sidepiece<EmptyBase<ST>> ParentType;

public:
    typedef EmptySidepiece<ST> SymmetricType;

protected:
    template <class... Args> EmptySidepiece(Args... args) : ParentType(args...) {}

    void findAllLateralReactions() override { assert(false); }
};

#endif // EMPTY_SIDEPIECE_H
