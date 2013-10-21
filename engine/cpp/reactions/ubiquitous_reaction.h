#ifndef CONCRETE_UBIQUITOUS_REACTION_H
#define CONCRETE_UBIQUITOUS_REACTION_H

#include "../generations/handbook.h" // TODO: need to except it
#include "reaction.h"

namespace vd
{

template <ushort RT>
class UbiquitousReaction : public Reaction
{
    Atom *_target;

public:
    UbiquitousReaction(Atom *target) : _target(target) {}

    void doIt() override;
    void remove() override;

protected:
    static short delta(Atom *anchor, const ushort *typeToNum);

    Atom *target() { return _target; }

    virtual short toType(ushort type) const = 0;
    virtual const ushort *onAtoms() const = 0;
    virtual void action() = 0;
};

template <ushort RT>
short UbiquitousReaction<RT>::delta(Atom *anchor, const ushort *typeToNum)
{
    ushort currNum = typeToNum[anchor->type()];
    ushort prevNum;
    if (anchor->prevType() == (ushort)(-1))
    {
        prevNum = 0;
    }
    else
    {
        prevNum = typeToNum[anchor->prevType()];
    }
    return currNum - prevNum;
}

template <ushort RT>
void UbiquitousReaction<RT>::remove()
{
    short dn = delta(_target, onAtoms());
    assert(dn < 0);
    Handbook::mc().removeMul<RT>(this, -dn);
}

template <ushort RT>
void UbiquitousReaction<RT>::doIt()
{
    uint type = toType(_target->type());
    assert(type != _target->type());

    action();
    _target->changeType(type);

    Atom *changedAtom = _target;
    remove();

    // Warning! Current object already deallocate self memory, therefore used changedAtom variable.
    changedAtom->findChildren();
}

}

#endif // CONCRETE_UBIQUITOUS_REACTION_H
