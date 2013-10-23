#include "dimer_formation.h"
#include "../../handbook.h"
#include <omp.h>

#include <assert.h>

void DimerFormation::find(BaseSpec *parent)
{
    Atom *anchor = parent->atom(0);

    assert(anchor->is(28));
    if (!anchor->prevIs(28))
    {
        assert(anchor->lattice());

        auto diamond = dynamic_cast<const Diamond *>(anchor->lattice()->crystal());
        assert(diamond);

        auto nbrs = diamond->front_100(anchor);
        // TODO: maybe do not need check existing role?
        if (nbrs[0] && nbrs[0]->is(28) && !anchor->hasBondWith(nbrs[0]) && nbrs[0]->hasRole(28, BRIDGE_CTs))
        {
            ReactionsMixin *targets[2] = {
                dynamic_cast<ReactionsMixin *>(parent),
                dynamic_cast<ReactionsMixin *>(nbrs[0]->specByRole(28, BRIDGE_CTs))
            };

            auto reaction = std::shared_ptr<Reaction>(new DimerFormation(targets));
            Handbook::mc().add<DIMER_FORMATION>(reaction.get());

            for (int i = 0; i < 2; ++i)
            {
                targets[i]->usedIn(reaction);
            }
        }
    }
}

void DimerFormation::doIt()
{
    Atom *atoms[2] = { target(0)->atom(0), target(1)->atom(0) };
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(28));
    assert(b->is(28));

    a->bondWith(b);

    a->changeType(22);
    b->changeType(22);

    Finder::findAll(atoms, 2);
}
