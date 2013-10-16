#ifndef REACTION_ACTIVATION_RECIPE_H
#define REACTION_ACTIVATION_RECIPE_H

#include "ubiquitous_reaction_recipe.h"

class ReactionActivationRecipe : public UbiquitousReactionRecipe
{
public:
    void find(Atom *anchor) const override;

protected:
    uint num(uint type) const { return Dictionary::hNum(type); }
};

#endif // REACTION_ACTIVATION_RECIPE_H
