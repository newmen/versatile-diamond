#include "dimer_drop.h"
#include "../../handbook.h"

#include <assert.h>

void DimerDrop::find(DimerCRiCLi *target)
{
    Atom *anchors[2] = { target->atom(0), target->atom(3) };

    assert(anchors[0]->is(20));
    assert(anchors[1]->is(20));

    // TODO: не уверен по поводу ||, может быть надо &&
    if (!anchors[0]->prevIs(20) || !anchors[1]->prevIs(20))
    {
        SpecReaction *reaction = new DimerDrop(target);
        Handbook::mc.add<DIMER_DROP>(reaction);

        target->usedIn(reaction);
    }
}

void DimerDrop::doIt()
{
    Atom *atoms[2] = { target()->atom(0), target()->atom(3) };
    Atom *a = atoms[0], *b = atoms[1];

    a->unbondFrom(b);

    changeAtom(a);
    changeAtom(b);

    Finder::findAll(atoms, 2);
}

void DimerDrop::remove()
{
    Handbook::mc.remove<DIMER_DROP>(this);
}

void DimerDrop::changeAtom(Atom *atom) const
{
    assert(atom->is(20));
    if (atom->is(21)) atom->changeType(2);
    else atom->changeType(28);
}
