#ifndef CONCRETE_UBIQUITOUS_REACTION_H
#define CONCRETE_UBIQUITOUS_REACTION_H

#include "../../../reactions/multi_reaction.h"
#include "../../handbook.h"

#ifdef PRINT
#include <iostream>
#endif // PRINT

namespace vd
{

template <ushort RT>
class UbiquitousReaction : public MultiReaction
{
    Atom *_target;

public:
    UbiquitousReaction(Atom *target) : _target(target) {}

    Atom *target() { return _target; }
    void doIt() override;

#ifdef PRINT
    void info() override;
#endif // PRINT

protected:
    static short delta(Atom *anchor, const ushort *typeToNum);

    virtual short toType(ushort type) const = 0;
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
void UbiquitousReaction<RT>::doIt()
{
    uint type = toType(_target->type());
    assert(type != _target->type());

    action();
    _target->changeType(type);

    Finder::findAll(&_target, 1);
}

#ifdef PRINT
template <ushort RT>
void UbiquitousReaction<RT>::info()
{
    std::cout << "Reaction " << RT << " [" << this << "]: " << target()->lattice()->coords() << std::endl;
}
#endif // PRINT

}

#endif // CONCRETE_UBIQUITOUS_REACTION_H
