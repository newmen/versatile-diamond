#ifndef REGISTRATOR_H
#define REGISTRATOR_H

#include <reactions/concrete_typical_reaction.h>
#include <reactions/concrete_lateral_reaction.h>
using namespace vd;

#include "typed_reaction.h"

template <class B, ushort RT>
class Registrator : public TypedReaction<B, RT>
{
    typedef TypedReaction<B, RT> ParentType;

public:
    void store() override;
    void remove() override;

protected:
    template <class... Args> Registrator(Args... args) : ParentType(args...) {}
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort RT>
void Registrator<B, RT>::store()
{
    ParentType::store();
    Handbook::mc().add(ParentType::ID, this);
}

template <class B, ushort RT>
void Registrator<B, RT>::remove()
{
    Handbook::mc().remove(ParentType::ID, this);
    ParentType::remove();
    Handbook::scavenger().markReaction(this);
}

#endif // REGISTRATOR_H
