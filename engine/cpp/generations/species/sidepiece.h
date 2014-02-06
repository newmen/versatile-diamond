#ifndef SIDEPIECE_H
#define SIDEPIECE_H

#include "../../species/sealer.h"
#include "../../species/lateral_spec.h"
using namespace vd;

#include "../handbook.h"

template <class B>
class Sidepiece : public Sealer<B, LateralSpec>
{
    typedef Sealer<B, LateralSpec> ParentType;

public:
    void remove() override;

protected:
    template <class... Args> Sidepiece(Args... args);

    void keepFirstTime() override;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B>
template <class... Args>
Sidepiece<B>::Sidepiece(Args... args) : ParentType(args...)
{
    static_assert(!std::is_base_of<LateralSpec, B>::value, "Specie already is lateral sidepiece");
}

template <class B>
void Sidepiece<B>::remove()
{
    if (this->isMarked()) return;

    ParentType::remove();
    this->unconcretizeReactions();
}

template <class B>
void Sidepiece<B>::keepFirstTime()
{
    Handbook::lateralKeeper().store(this);
}

#endif // SIDEPIECE_H
