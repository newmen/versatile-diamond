#ifndef BRIDGE_CTS_RECIPE_H
#define BRIDGE_CTS_RECIPE_H

#include "../atomic_recipe.h"

class BridgeCtsRecipe : public AtomicRecipe
{
public:
    void find(Atom *anchor) const override;
};

#endif // BRIDGE_CTS_RECIPE_H
