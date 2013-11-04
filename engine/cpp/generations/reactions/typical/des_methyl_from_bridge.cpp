#include "des_methyl_from_bridge.h"
#include "../../handbook.h"

void DesMethylFromBridge::find(MethylOnBridgeCBiCMu *target)
{
    Atom *anchors[2] = { target->atom(0), target->atom(1) };

    assert(anchors[0]->is(25));
    assert(anchors[1]->is(7));

    if (!anchors[0]->prevIs(25) || !anchors[1]->prevIs(7))
    {
        SpecReaction *reaction = new DesMethylFromBridge(target);
        Handbook::mc.add<DES_METHYL_FROM_BRIDGE>(reaction);

        target->usedIn(reaction); // TODO: move to reaction constructor?
    }
}

void DesMethylFromBridge::doIt()
{
    Atom *atoms[2] = { target()->atom(0), target()->atom(1) };
    Atom *a = atoms[0], *b = atoms[1];

    a->unbondFrom(b);

    assert(b->is(7));
    if (b->is(8)) b->changeType(2);
    else b->changeType(28);

    Handbook::amorph.remove(a);
    Finder::findAll(atoms, 2);
}

void DesMethylFromBridge::remove()
{
    Handbook::mc.remove<DES_METHYL_FROM_BRIDGE>(this);
}
