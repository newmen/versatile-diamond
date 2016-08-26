#ifndef EMPTY_SPECIFIC_SIDEPIECE_H
#define EMPTY_SPECIFIC_SIDEPIECE_H

#include "empty_specific.h"
#include "sidepiece.h"

template <ushort ST>
class EmptySpecificSidepiece : public Sidepiece<EmptySpecific<ST>>
{
    typedef Sidepiece<EmptySpecific<ST>> ParentType;

public:
    typedef EmptySpecificSidepiece<ST> SymmetricType;

protected:
    template <class... Args> EmptySpecificSidepiece(Args... args) : ParentType(args...) {}

    void findAllLateralReactions() override { assert(false); }
};

#endif // EMPTY_SPECIFIC_SIDEPIECE_H
