#include "reaction_activation_recipe.h"

void ReactionActivationRecipe::find(Atom *anchor) const
{
    if (anchor->is(12)) return;

    short dn = delta(anchor);
    if (dn > 0)
    {
        Dictionary::mc().addActivations(new ReactionActivation(anchor), dn);
    }
}

short ReactionActivationRecipe::delta(Atom *anchor) const
{
    uint currNum = Dictionary::hNum(anchor->type());
    uint prevNum;
    if (anchor->prevType() == (uint)(-1))
    {
        prevNum = 0;
    }
    else
    {
        prevNum = Dictionary::hNum(anchor->prevType());
    }
    return currNum - prevNum;
}
