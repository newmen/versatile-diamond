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
    Atom *atoms[2] = { target()->atom(1) };
    Atom *a = atoms[0], *b = target()->atom(0);

    a->unbondFrom(b);

    assert(a->is(7));
    if (a->is(8)) a->changeType(2);
    else a->changeType(28);

    b->prepareToRemove();
    Handbook::amorph.erase(b);
    Handbook::scavenger.markAtom(b);

    Finder::findAll(atoms, 1);
}

void DesMethylFromBridge::remove()
{
    Handbook::mc.remove<DES_METHYL_FROM_BRIDGE>(this);
}
