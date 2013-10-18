#include "reaction_deactivation.h"
#include "../../handbook.h"
#include "../../recipes/reactions/ubiquitous/reaction_deactivation_recipe.h"

short ReactionDeactivation::toType(uint type) const
{
    return Handbook::activesToH(type);
}

void ReactionDeactivation::remove()
{
    ReactionDeactivationRecipe rdr;
    short dn = rdr.delta(target());
    assert(dn < 0);
    Handbook::mc().removeDeactivations(this, -dn);
}
