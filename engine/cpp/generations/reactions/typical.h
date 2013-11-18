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

    void store() override;

protected:
    static bool find(SpecificSpec *target, const ushort *indexes, const ushort *types, ushort atomsNum);

    void remove() override;
};

template <class B, ushort RT>
void Typical<B, RT>::store()
{
    Handbook::mc().add<RT>(this);
}

template <class B, ushort RT>
bool Typical<B, RT>::find(SpecificSpec *target, const ushort *indexes, const ushort *types, ushort atomsNum)
{
    for (int i = 0; i < atomsNum; ++i)
    {
        Atom *anchor = target->atom(indexes[i]);
        assert(anchor->is(types[i]));

        if (!anchor->prevIs(types[i])) return true;
    }

    return false;
}

template <class B, ushort RT>
void Typical<B, RT>::remove()
{
    Handbook::mc().remove<RT>(this);
    Handbook::scavenger().markReaction<RT>(this);
}

#endif // TYPICAL_H
