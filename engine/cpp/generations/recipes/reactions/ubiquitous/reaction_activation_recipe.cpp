#include "reaction_activation_recipe.h"

void ReactionActivationRecipe::find(Atom *anchor) const
{
    if (anchor->is(25)) return;

    short dn = delta(anchor);
    if (dn > 0)
    {
        Dictionary::mc().addActivations(new ReactionActivation(anchor), dn);
    }
}
