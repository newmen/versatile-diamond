#ifndef REACTION_DEACTIVATION_RECIPE_H
#define REACTION_DEACTIVATION_RECIPE_H

#include "ubiquitous_reaction_recipe.h"

class ReactionDeactivationRecipe : public UbiquitousReactionRecipe
{
public:
    void find(Atom *anchor) const override;

protected:
    ushort num(ushort type) const { return Handbook::activesNum(type); }
};

#endif // REACTION_DEACTIVATION_RECIPE_H
