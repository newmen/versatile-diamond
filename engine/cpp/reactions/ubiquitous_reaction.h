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
    static short currNum(const Atom *anchor, const ushort *typeToNum);
    static short prevNum(const Atom *anchor, const ushort *typeToNum);

    UbiquitousReaction(Atom *target) : _target(target) {}

public:
    Atom *target() { return _target; }
    const Atom *target() const { return _target; } // should be replaced to .anchor() call everywhere

    Atom *anchor() const override;

#ifdef PRINT
    void info(std::ostream &os) override;
#endif // PRINT

protected:
    virtual void changeAtoms(Atom **) override;
    virtual ushort toType() const = 0;
    virtual void action() = 0;
};

}

#endif // CONCRETE_UBIQUITOUS_REACTION_H
