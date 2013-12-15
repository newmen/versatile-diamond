#ifndef CONCRETIZABLE_ROLE_H
#define CONCRETIZABLE_ROLE_H

#include "../../species/lateral_spec.h"
using namespace vd;

#include "../handbook.h"

template <class B>
class ConcretizableRole : public B
{
public:
    template <class R>
    void concretize(LateralSpec *spec);

protected:
    template <class... Args>
    ConcretizableRole(Args... args) : B(args...) {}
};

template <class B>
template <class R>
void ConcretizableRole<B>::concretize(LateralSpec *spec)
{
    Handbook::mc().remove(B::ID, this);
    this->eraseFromTargets(this);

    Creator::createBy<R>(this, spec);
}

#endif // CONCRETIZABLE_ROLE_H
