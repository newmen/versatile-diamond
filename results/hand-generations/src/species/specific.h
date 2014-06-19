#ifndef SPECIFIC_H
#define SPECIFIC_H

#include <species/sealer.h>
#include <species/specific_spec.h>
using namespace vd;

#include "../handbook.h"

template <class B>
class Specific : public Sealer<B, SpecificSpec>
{
    typedef Sealer<B, SpecificSpec> ParentType;

public:
    void remove() override;

protected:
    template <class... Args> Specific(Args... args);

    void keepFirstTime() override;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B>
template <class... Args>
Specific<B>::Specific(Args... args) : ParentType(args...)
{
    static_assert(!std::is_base_of<SpecificSpec, B>::value, "Specie already is specific");
}

template <class B>
void Specific<B>::remove()
{
    if (this->isMarked()) return;

    ParentType::remove();
    this->removeReactions();
}

template <class B>
void Specific<B>::keepFirstTime()
{
    Handbook::specificKeeper().store(this);
}

#endif // SPECIFIC_H
