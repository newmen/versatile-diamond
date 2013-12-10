#ifndef BASE_H
#define BASE_H

#include <assert.h>
#include "../../tools/typed.h"
#include "../../atoms/crystal_atoms_iterator.h"
using namespace vd;

#include "../handbook.h"

template <class B, ushort ST, ushort USED_ATOMS_NUM>
class Base : public Typed<B, ST>, public CrystalAtomsIterator
{
protected:
//    using Typed<B, ST>::Typed;
    template <class... Args>
    Base(Args... args) : Typed<B, ST>(args...) {}

public:
    void store() override;
    void remove() override;
};

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Base<B, ST, USED_ATOMS_NUM>::store()
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

    this->findChildren();
}

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Base<B, ST, USED_ATOMS_NUM>::remove()
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

    Handbook::scavenger().markSpec<ST>(this);
}

#endif // BASE_H
