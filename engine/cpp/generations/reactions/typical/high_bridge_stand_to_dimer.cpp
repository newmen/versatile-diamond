#include "high_bridge_stand_to_dimer.h"

void HighBridgeStandToDimer::find(HighBridge *target)
{
    Atom *anchor = target->anchor();
    eachNeighbour(anchor, &Diamond::front_100, [target](Atom *neighbour) {
        if (neighbour->is(21))
        {
            auto neighbourSpec = neighbour->specByRole<DimerCRsCLi>(21);
            if (neighbourSpec)
            {
                SpecificSpec *targets[2] = {
                    target,
                    neighbourSpec
                };

                create<HighBridgeStandToDimer>(targets);
            }
        }
    });
}

void HighBridgeStandToDimer::find(DimerCRsCLi *target)
{
    // TODO: maybe need get anchor atom of DimerCRsCLi through DimerCRs
    Atom *anchor = target->anchor();
    eachNeighbour(anchor, &Diamond::front_100, [target](Atom *neighbour) {
        if (neighbour->is(19))
        {
            auto neighbourSpec = neighbour->specByRole<HighBridge>(19);
            assert(neighbourSpec);

            SpecificSpec *targets[2] = {
                neighbourSpec,
                target
            };

            create<HighBridgeStandToDimer>(targets);
        }
    });
}

void HighBridgeStandToDimer::doIt()
{
    SpecificSpec *highBridge = target(0);
    SpecificSpec *dimerCRsCLi = target(1);

    assert(highBridge->type() == HighBridge::ID);
    assert(dimerCRsCLi->type() == DimerCRsCLi::ID);

    Atom *atoms[3] = { highBridge->atom(0), highBridge->atom(1), dimerCRsCLi->atom(0) };
    Atom *a = atoms[0], *b = atoms[1], *c = atoms[2];

    assert(a->is(18));
    assert(b->is(19));
    assert(c->is(21));

    a->unbondFrom(b);
    a->bondWith(c);

    Handbook::amorph().erase(a);
    assert(b->lattice()->crystal() == c->lattice()->crystal());
    crystalBy(b)->insert(a, Diamond::front_110_at(b, c));

    if (a->is(17)) a->changeType(2);
    else if (a->is(16)) a->changeType(1);
    else a->changeType(3);

    b->changeType(5);
    c->changeType(32);

    Finder::findAll(atoms, 3);
}

const char *HighBridgeStandToDimer::name() const
{
    static const char value[] = "high bridge stand to dimer";
    return value;
}
