#include "reaction_activation.h"
#include "../../dictionary.h"
#include "../../recipes/reactions/ubiquitous/reaction_activation_recipe.h"

short ReactionActivation::toType(uint type) const
{
    return Dictionary::hToActives(type);
}

void ReactionActivation::remove()
{
    ReactionActivationRecipe rar;
    short dn = rar.delta(target());
    assert(dn < 0);
    Dictionary::mc().removeActivations(this, -dn);
}
