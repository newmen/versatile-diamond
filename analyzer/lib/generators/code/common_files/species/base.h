#ifndef BASE_H
#define BASE_H

#include <species/localable_role.h>
using namespace vd;

#include "overall.h"

template <class B, ushort ST, ushort USED_ATOMS_NUM>
class Base : public Overall<B, ST>
{
    typedef Overall<B, ST> ParentType;

protected:
    static const ushort __indexes[USED_ATOMS_NUM];
    static const ushort __roles[USED_ATOMS_NUM];

public:
    void store() override;
    void remove() override;

protected:
    template <class... Args> Base(Args... args) : ParentType(args...) {}
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Base<B, ST, USED_ATOMS_NUM>::store()
{
    for (uint i = 0; i < USED_ATOMS_NUM; ++i)
    {
        this->atom(__indexes[i])->describe(__roles[i], this);
    }

    ParentType::store();
}

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Base<B, ST, USED_ATOMS_NUM>::remove()
{
    if (this->isMarked()) return;

    for (uint i = 0; i < USED_ATOMS_NUM; ++i)
    {
        this->atom(__indexes[i])->forget(__roles[i], this);
    }

    ParentType::remove();
}

#endif // BASE_H
