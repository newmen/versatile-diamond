#ifndef REACTION_ACTIVATION_RECIPE_H
#define REACTION_ACTIVATION_RECIPE_H

#include "../../base_recipe.h"

class ReactionActivationRecipe : public BaseRecipe
{
public:
    void find(Atom *anchor) const override;

    short delta(Atom *anchor) const;
};

#endif // REACTION_ACTIVATION_RECIPE_H
