#ifndef CONCRETE_UBIQUITOUS_REACTION_H
#define CONCRETE_UBIQUITOUS_REACTION_H

#include "reaction.h"

namespace vd
{

class UbiquitousReaction : public Reaction
{
    Atom *_target;

protected:
    static short delta(const Atom *anchor, const ushort *typeToNum);
    static ushort currNum(const Atom *anchor, const ushort *typeToNum);
    static ushort prevNum(const Atom *anchor, const ushort *typeToNum);

    UbiquitousReaction(Atom *target) : _target(target) {}

public:
    Atom *target() { return _target; }
    const Atom *target() const { return _target; }

    void doIt() override;

#if defined(PRINT) || defined(MC_PRINT)
    void info(IndentStream &os) override;
#endif // PRINT || MC_PRINT

protected:
    virtual ushort toType() const = 0;
    virtual void action() = 0;
};

}

#endif // CONCRETE_UBIQUITOUS_REACTION_H
