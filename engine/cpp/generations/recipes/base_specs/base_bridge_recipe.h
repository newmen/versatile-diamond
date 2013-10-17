#ifndef BASE_BRIDGE_RECIPE_H
#define BASE_BRIDGE_RECIPE_H

#include "../atomic_recipe.h"

class BaseBridgeRecipe : public AtomicRecipe
{
public:
    void find(Atom *anchor) const override;

private:
    void findChildren(Atom *anchor) const;
};

#endif // BASE_BRIDGE_RECIPE_H
