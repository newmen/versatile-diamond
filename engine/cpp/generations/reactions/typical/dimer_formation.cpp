#include "dimer_formation.h"
#include "../../handbook.h"
#include <omp.h>

#include <assert.h>

void DimerFormation::find(SpecificSpec *parent)
{
    Atom *anchor = parent->atom(0);

    assert(anchor->is(28));
    if (!anchor->prevIs(28))
    {
        assert(anchor->lattice());
        auto diamond = static_cast<const Diamond *>(anchor->lattice()->crystal());

        auto nbrs = diamond->front_100(anchor);
        // TODO: maybe need to parallel it?
        if (nbrs[0]) checkAndAdd(parent, nbrs[0]);
        if (nbrs[1] && nbrs[1]->isVisited()) checkAndAdd(parent, nbrs[1]);
    }
}

void DimerFormation::doIt()
{
    Atom *atoms[2] = { target(0)->atom(0), target(1)->atom(0) };
    Atom *a = atoms[0], *b = atoms[1];

    a->bondWith(b);

    changeAtom(a);
    changeAtom(b);

    Finder::findAll(atoms, 2);
}

void DimerFormation::remove()
{
    Handbook::mc().remove<DIMER_FORMATION>(this, false);
    Handbook::scavenger().storeReaction<SCA_DIMER_FORMATION>(this);
}

void DimerFormation::checkAndAdd(SpecificSpec *parent, Atom *neighbour)
{
    // TODO: maybe do not need check existing role?
    if (neighbour->is(28) && !parent->atom(0)->hasBondWith(neighbour) && neighbour->hasRole(28, BRIDGE_CTsi))
    {
        SpecificSpec *targets[2] = {
            parent,
            static_cast<SpecificSpec *>(neighbour->specByRole(28, BRIDGE_CTsi))
        };

        SpecReaction *reaction = new DimerFormation(targets);
        Handbook::mc().add<DIMER_FORMATION>(reaction);

        for (int i = 0; i < 2; ++i)
        {
            targets[i]->usedIn(reaction);
        }
    }
}

void DimerFormation::changeAtom(Atom *atom) const
{
    assert(atom->is(28));

    if (atom->type() == 28) atom->changeType(20);
    else if (atom->type() == 2) atom->changeType(21);
    else assert(true);
}
