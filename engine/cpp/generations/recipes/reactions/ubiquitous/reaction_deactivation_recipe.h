#ifndef REACTION_DEACTIVATION_RECIPE_H
#define REACTION_DEACTIVATION_RECIPE_H

#include "ubiquitous_reaction_recipe.h"

class ReactionDeactivationRecipe : public UbiquitousReactionRecipe
{
public:
    void find(Atom *anchor) const override;

protected:
    uint num(uint type) const { return Dictionary::activesNum(type); }
};

#endif // REACTION_DEACTIVATION_RECIPE_H
