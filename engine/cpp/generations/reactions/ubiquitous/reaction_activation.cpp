#include "reaction_activation.h"
#include "../../handbook.h"
#include "../../recipes/reactions/ubiquitous/reaction_activation_recipe.h"

short ReactionActivation::toType(uint type) const
{
    return Handbook::hToActives(type);
}

void ReactionActivation::remove()
{
    ReactionActivationRecipe rar;
    short dn = rar.delta(target());
    assert(dn < 0);
    Handbook::mc().removeActivations(this, -dn);
}
