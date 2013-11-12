#ifndef BASE_H
#define BASE_H

#include "typed.h"

template <class B, ushort ST, ushort USED_ATOMS_NUM>
class Base : public Typed<B, ST, USED_ATOMS_NUM>
{
protected:
//    using Typed::Typed;
    template <class... Args>
    Base(Args... args) : Typed<B, ST, USED_ATOMS_NUM>(args...) {}

    void correspondFindChildren() final;
};

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Base<B, ST, USED_ATOMS_NUM>::correspondFindChildren()
{
    this->findChildren();
}

#endif // BASE_H
