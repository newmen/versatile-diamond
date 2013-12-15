#ifndef UBIQUITOUS_H
#define UBIQUITOUS_H

#include "../../reactions/ubiquitous_reaction.h"
#include "../../tools/typed.h"
using namespace vd;

#include "../finder.h"
#include "../handbook.h"

template <ushort RT>
class Ubiquitous : public Typed<UbiquitousReaction, RT>
{
    typedef Typed<UbiquitousReaction, RT> ParentType;

public:
    void doIt() override;

protected:
    Ubiquitous(Atom *target) : ParentType(target) {}

    template <class R>
    static void find(Atom *anchor, short delta);

private:
    enum : ushort { MC_INDEX = RT - SURFACE_ACTIVATION }; // must used first ID of ubiquitous reactions names

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
    Handbook::mc().add(MC_INDEX, new R(anchor), delta);
}

template <ushort RT>
template <class R>
void Ubiquitous<RT>::remove(Atom *anchor, short delta)
{
    R removableTemplate(anchor);
    Handbook::mc().remove(MC_INDEX, &removableTemplate, -delta);
}

template <ushort RT>
void Ubiquitous<RT>::doIt()
{
    UbiquitousReaction::doIt();

    Atom *atoms[1] = { this->target() };
    Finder::findAll(atoms, 1);
}

#endif // UBIQUITOUS_H
