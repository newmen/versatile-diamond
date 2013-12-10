#ifndef TYPICAL_H
#define TYPICAL_H

#include "../../atoms/crystal_atoms_iterator.h"
#include "../../reactions/counterable.h"
#include "../../tools/typed.h"
using namespace vd;

#include "../handbook.h"

template <class B, ushort RT>
class Typical : public Counterable<Typed<B, RT>, RT>, public CrystalAtomsIterator
{
public:
    void store() override;

protected:
//    using Counterable<Typed<B, RT>, RT>, RT>::Counterable;
    template <class... Args>
    Typical(Args... args) : Counterable<Typed<B, RT>, RT>(args...) {}

    void remove() override;
};

template <class B, ushort RT>
void Typical<B, RT>::store()
{
    Handbook::mc().add(this);
}

template <class B, ushort RT>
void Typical<B, RT>::remove()
{
    Handbook::mc().remove(this);
    Handbook::scavenger().markReaction<RT>(this);
}

#endif // TYPICAL_H
