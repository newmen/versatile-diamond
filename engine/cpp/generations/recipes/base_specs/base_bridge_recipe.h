#ifndef BASE_BRIDGE_RECIPE_H
#define BASE_BRIDGE_RECIPE_H

#include "../base_recipe.h"

class BaseBridgeRecipe : public BaseRecipe
{
public:
    void find(Atom *anchor) const override;

private:
    void findChildren(Atom *anchor) const override;
};

#endif // BASE_BRIDGE_RECIPE_H
