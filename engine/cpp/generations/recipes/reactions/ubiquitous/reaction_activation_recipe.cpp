#include "reaction_activation_recipe.h"

void ReactionActivationRecipe::find(Atom *anchor) const
{
    if (anchor->is(25)) return;

    short dn = delta(anchor);
    if (dn > 0)
    {
        Handbook::mc().addActivations(new ReactionActivation(anchor), dn);
    }
}
