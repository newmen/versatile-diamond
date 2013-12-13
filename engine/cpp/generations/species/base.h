#ifndef BASE_H
#define BASE_H

#include "../../tools/typed.h"
using namespace vd;

#include "../phases/diamond_atoms_iterator.h"
#include "../handbook.h"

template <class B, ushort USED_ATOMS_NUM = B::UsedAtomsNum>
class Base : public B, public DiamondAtomsIterator
{
protected:
    template <class... Args>
    Base(Args... args) : B(args...) {}

public:
    void store() override;
    void remove() override;
};

template <class B, ushort USED_ATOMS_NUM>
void Base<B, USED_ATOMS_NUM>::store()
{
#ifdef PRINT
    this->wasFound();
#endif // PRINT

    ushort *idxs = this->indexes();
    ushort *rls = this->roles();

    for (uint i = 0; i < USED_ATOMS_NUM; ++i)
    {
        this->atom(idxs[i])->describe(rls[i], this);
    }

    B::store();
}

template <class B, ushort USED_ATOMS_NUM>
void Base<B, USED_ATOMS_NUM>::remove()
{
#ifdef PRINT
    this->wasForgotten();
#endif // PRINT

    B::remove();

    ushort *idxs = this->indexes();
    ushort *rls = this->roles();

    for (uint i = 0; i < USED_ATOMS_NUM; ++i)
    {
        this->atom(idxs[i])->forget(rls[i], this);
    }

    Handbook::scavenger().markSpec(this);
}

#endif // BASE_H
