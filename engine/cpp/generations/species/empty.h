#ifndef EMPTY_H
#define EMPTY_H

#include "overall.h"

template <class B, ushort ST>
class Empty : public Overall<B, ST>
{
    typedef Overall<B, ST> ParentType;

public:
    // works only if B contain DependentSpec
    Atom *anchor() const override { return this->parent(0)->anchor(); }

protected:
    template <class... Args>
    Empty(Args... args) : ParentType(args...) {}
};

#endif // EMPTY_H
