#ifndef TYPICAL_H
#define TYPICAL_H

#include "../handbook.h"

template <class B, ushort RT>
class Typical : public B
{
public:
//    using B::B;
    template <class... Args>
    Typical(Args... args) : B(args...) {}

    ushort type() const override { return RT; }
    void store() override;

protected:
    void remove() override;
};

template <class B, ushort RT>
void Typical<B, RT>::store()
{
    Handbook::mc().add<RT>(this);
}

template <class B, ushort RT>
void Typical<B, RT>::remove()
{
    Handbook::mc().remove<RT>(this);
    Handbook::scavenger().markReaction<RT>(this);
}

#endif // TYPICAL_H
