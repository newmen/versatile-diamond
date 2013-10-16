#include "reaction_deactivation.h"
#include "../../dictionary.h"
#include "../../recipes/reactions/ubiquitous/reaction_deactivation_recipe.h"

short ReactionDeactivation::toType(uint type) const
{
    return Dictionary::activesToH(type);
}

void ReactionDeactivation::remove()
{
    ReactionDeactivationRecipe rdr;
    short dn = rdr.delta(target());
    assert(dn < 0);
    Dictionary::mc().removeDeactivations(this, -dn);
}
