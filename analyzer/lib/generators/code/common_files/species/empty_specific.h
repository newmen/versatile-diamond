#ifndef EMPTY_SPECIFIC_H
#define EMPTY_SPECIFIC_H

#include "empty_base.h"
#include "specific.h"

template <ushort ST>
class EmptySpecific : public Specific<EmptyBase<ST>>
{
    typedef Specific<EmptyBase<ST>> ParentType;

public:
    typedef EmptySpecific<ST> SymmetricType;

protected:
    template <class... Args> EmptySpecific(Args... args) : ParentType(args...) {}

    void findAllTypicalReactions() override {}
};

#endif // EMPTY_SPECIFIC_H
