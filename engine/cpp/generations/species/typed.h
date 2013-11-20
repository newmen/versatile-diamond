#ifndef TYPED_H
#define TYPED_H

#include "../../tools/common.h"
using namespace vd;

#include "../handbook.h"

#include <assert.h>

template <class B, ushort ST, ushort USED_ATOMS_NUM>
class Typed : public B
{
protected:
//    using B::B;
    template <class... Args>
    Typed(Args... args) : B(args...) {}

//    virtual ushort *indexes() const = 0;
//    virtual ushort *roles() const = 0;

public:
    static const Diamond *diamondBy(Atom *atom);

    ushort type() const override { return ST; }

    void store() override;
    void remove() override;
};

template <class B, ushort ST, ushort USED_ATOMS_NUM>
const Diamond *Typed<B, ST, USED_ATOMS_NUM>::diamondBy(Atom *atom)
{
    assert(atom->lattice());
    return static_cast<const Diamond *>(atom->lattice()->crystal());
}

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Typed<B, ST, USED_ATOMS_NUM>::store()
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
void Typed<B, ST, USED_ATOMS_NUM>::remove()
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

#endif // TYPED_H
