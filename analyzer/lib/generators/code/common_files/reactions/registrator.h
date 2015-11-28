#ifndef REGISTRATOR_H
#define REGISTRATOR_H

#include <reactions/concrete_typical_reaction.h>
#include <reactions/concrete_lateral_reaction.h>
#include <reactions/multi_lateral_reaction.h>
#include <tools/typed.h>
using namespace vd;

#include "../handbook.h"
#include "rates_reader.h"

template <class B, ushort RT>
class Registrator : public Typed<B, RT>, public RatesReader
{
    typedef Typed<B, RT> ParentType;

public:
    void remove() override;

protected:
    template <class... Args> Registrator(Args... args) : ParentType(args...) {}

    void mcRemember() override; // should be final
    void mcForget() override; // should be final
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort RT>
void Registrator<B, RT>::remove()
{
    ParentType::remove();
    Handbook::scavenger().markReaction(this);
}

template <class B, ushort RT>
void Registrator<B, RT>::mcRemember()
{
    Handbook::mc().add(ParentType::ID, this);
}

template <class B, ushort RT>
void Registrator<B, RT>::mcForget()
{
    Handbook::mc().remove(ParentType::ID, this);
}

#endif // REGISTRATOR_H
