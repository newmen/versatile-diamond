#include "reaction_deactivation_recipe.h"
#include "../../../reactions/ubiquitous/reaction_deactivation.h"

void ReactionDeactivationRecipe::find(Atom *anchor) const
{
    if (anchor->is(26)) return;

    short dn = delta(anchor);
    if (dn > 0)
    {
        Handbook::mc().addDeactivations(new ReactionDeactivation(anchor), dn);
    }
}
