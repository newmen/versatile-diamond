#ifndef LOCALABLE_ROLE_H
#define LOCALABLE_ROLE_H

#include "../atoms/atom.h"

namespace vd
{

template <class B, ushort TARGET_ATOM_INDEX>
class LocalableRole : public B
{
public:
    void store() override;
    void remove() override;

protected:
    template <class... Args> LocalableRole(Args... args) : B(args...) {}

    virtual void concretizeLocal(Atom *target) const = 0;
    virtual void unconcretizeLocal(Atom *target) const = 0;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort TARGET_ATOM_INDEX>
void LocalableRole<B, TARGET_ATOM_INDEX>::store()
{
    B::store();

    Atom *target = this->atom(TARGET_ATOM_INDEX);
    if (target->isVisited())
    {
        concretizeLocal(target);
    }
}

template <class B, ushort TARGET_ATOM_INDEX>
void LocalableRole<B, TARGET_ATOM_INDEX>::remove()
{
    B::remove();

    Atom *target = this->atom(TARGET_ATOM_INDEX);
    if (target->isVisited())
    {
        unconcretizeLocal(target);
    }
}

}

#endif // LOCALABLE_ROLE_H
