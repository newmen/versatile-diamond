#ifndef TYPED_H
#define TYPED_H

#include <sstream>
#include "common.h"

namespace vd
{

template <class B, ushort BT>
class Typed : public B
{
public:
    enum : ushort { ID = BT };
    ushort type() const override { return BT; }

protected:
    template <class... Args> Typed(Args... args) : B(args...) {}
};

}

#endif // TYPED_H
