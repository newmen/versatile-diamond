#ifndef LATERABLE_H
#define LATERABLE_H

#include "../../species/specific_spec.h"
#include "../../reactions/lateral_reaction.h"
using namespace vd;

#include "concretizable.h"

template <class B>
class Laterable : public Concretizable<B>
{
    typedef Concretizable<B> ParentType;

public:
    void store() override;

protected:
    template <class... Args>
    Laterable(Args... args);

    virtual LateralReaction *findLateral() = 0;
};

template <class B>
template <class... Args>
Laterable<B>::Laterable(Args... args) : ParentType(args...)
{
    static_assert(!std::is_base_of<LateralReaction, B>::value, "Template argument should not derive LateralReaction");
}

template <class B>
void Laterable<B>::store()
{
    auto lateralReaction = findLateral();
    if (lateralReaction)
    {
        lateralReaction->store();
    }
    else
    {
        B::store();
    }
}

#endif // LATERABLE_H
