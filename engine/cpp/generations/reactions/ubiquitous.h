#ifndef UBIQUITOUS_H
#define UBIQUITOUS_H

#include "../../reactions/counterable.h"
#include "../../reactions/ubiquitous_reaction.h"
using namespace vd;

#include "../finder.h"
#include "../handbook.h"

template <ushort RT>
class Ubiquitous : public Counterable<UbiquitousReaction, RT>
{
public:
    ushort type() const override { return RT - ALL_SPEC_REACTIONS_NUM; }

    void doIt() override;

protected:
//    using Counterable<UbiquitousReaction, RT>::Counterable;
    Ubiquitous(Atom *target) : Counterable<UbiquitousReaction, RT>(target) {}

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
    Handbook::mc().add(new R(anchor), delta);
}

template <ushort RT>
template <class R>
void Ubiquitous<RT>::remove(Atom *anchor, short delta)
{
    R removableTemplate(anchor);
    Handbook::mc().remove(&removableTemplate, -delta);
}


template <ushort RT>
void Ubiquitous<RT>::doIt()
{
    UbiquitousReaction::doIt();

    Atom *atoms[1] = { this->target() };
    Finder::findAll(atoms, 1);
}

#endif // UBIQUITOUS_H
