#ifndef UBIQUITOUS_H
#define UBIQUITOUS_H

#include "../../reactions/ubiquitous_reaction.h"
using namespace vd;

#include "../finder.h"
#include "../handbook.h"

template <ushort RT>
class Ubiquitous : public UbiquitousReaction
{
public:
//    using UbiquitousReaction::UbiquitousReaction;
    Ubiquitous(Atom *target) : UbiquitousReaction(target) {}

    ushort type() const override { return RT; } // same as in Typical

    void doIt() override;

protected:
    template <class R>
    static void find(Atom *anchor, short delta);

private:
    template <class R>
    static void store(Atom *anchor, short delta);

    template <class R>
    static void remove(Atom *anchor, short delta);
};

template <ushort RT>
template <class R>
void Ubiquitous<RT>::find(Atom *anchor, short delta)
{
    if (delta > 0)
    {
        store<R>(anchor, delta);
    }
    else if (delta < 0)
    {
        remove<R>(anchor, delta);
    }
}

template <ushort RT>
template <class R>
void Ubiquitous<RT>::store(Atom *anchor, short delta)
{
    Handbook::mc().addMul<RT - TypicalReactionsNum>(new R(anchor), delta);
}

template <ushort RT>
template <class R>
void Ubiquitous<RT>::remove(Atom *anchor, short delta)
{
    R removableTemplate(anchor);
    Handbook::mc().removeMul<RT - TypicalReactionsNum>(&removableTemplate, -delta);
}


template <ushort RT>
void Ubiquitous<RT>::doIt()
{
    UbiquitousReaction::doIt();

    Atom *atoms[1] = { target() };
    Finder::findAll(atoms, 1);
}

#endif // UBIQUITOUS_H
