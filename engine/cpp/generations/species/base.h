#ifndef BASE_H
#define BASE_H

#include "overall.h"

template <class B, ushort ST, ushort USED_ATOMS_NUM>
class Base : public Overall<B, ST>
{
    typedef Overall<B, ST> ParentType;

public:
    Atom *anchor() const override { return this->atom(indexes()[0]); }

    void store() override;
    void remove() override;

protected:
    template <class... Args>
    Base(Args... args) : ParentType(args...) {}

    virtual const ushort *indexes() const = 0;
    virtual const ushort *roles() const = 0;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Base<B, ST, USED_ATOMS_NUM>::store()
{
    const ushort *idxs = this->indexes();
    const ushort *rls = this->roles();

    for (uint i = 0; i < USED_ATOMS_NUM; ++i)
    {
        this->atom(idxs[i])->describe(rls[i], this);
    }

    // parent store must be called after describe spec to atoms,
    // for correct order of removing unsupported specs from atoms
    ParentType::store();
}

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Base<B, ST, USED_ATOMS_NUM>::remove()
{
    const ushort *idxs = this->indexes();
    const ushort *rls = this->roles();

    for (uint i = 0; i < USED_ATOMS_NUM; ++i)
    {
        this->atom(idxs[i])->forget(rls[i], this);
    }

    ParentType::remove();
}

#endif // BASE_H
