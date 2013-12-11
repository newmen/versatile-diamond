#ifndef TYPICAL_H
#define TYPICAL_H

#include "../../reactions/counterable.h"
#include "../../tools/typed.h"
using namespace vd;

#include "../phases/diamond_atoms_iterator.h"
#include "../handbook.h"

template <class B, ushort RT>
class Typical : public Counterable<Typed<B, RT>, RT>, public DiamondAtomsIterator
{
    typedef Counterable<Typed<B, RT>, RT> ParentType;

public:
    void store() override;

protected:
    template <class... Args>
    Typical(Args... args) : ParentType(args...) {}

    void remove() override;
};

template <class B, ushort RT>
void Typical<B, RT>::store()
{
    ParentType::store();
    Handbook::mc().add(this);
}

template <class B, ushort RT>
void Typical<B, RT>::remove()
{
    Handbook::mc().remove(this);
    Handbook::scavenger().markReaction(this);
}

#endif // TYPICAL_H
