#ifndef COUNTERABLE_H
#define COUNTERABLE_H

#include "../tools/common.h"

namespace vd
{

template <class B, ushort ID>
class Counterable : public B
{
public:
    ushort counterIndex() const override { return ID; }

protected:
//    using B::B;
    template <class... Args>
    Counterable(Args... args) : B(args...) {}
};

}


#endif // COUNTERABLE_H
