#ifndef CONCRETIZABLE_H
#define CONCRETIZABLE_H

#include "../../species/lateral_spec.h"
#include "../../reactions/wrappable_reaction.h"
using namespace vd;

template <class B>
class Concretizable : public B
{
public:
    template <class R>
    void concretize(LateralSpec *spec);

protected:
    template <class... Args>
    Concretizable(Args... args) : B(args...) {}
};

template <class B>
template <class R>
void Concretizable<B>::concretize(LateralSpec *spec)
{
    this->removeFromAll();
    Handbook::mc().remove(this);

    Creator::createBy<R>(this, spec);
}

#endif // CONCRETIZABLE_H
