#ifndef TYPED_H
#define TYPED_H

#include "common.h"

namespace vd
{

template <class B, ushort ID>
class Typed : public B
{
public:
    ushort type() const override { return ID; }

protected:
//    using B::B;
    template <class... Args>
    Typed(Args... args) : B(args...) {}
};

}

#endif // TYPED_H
