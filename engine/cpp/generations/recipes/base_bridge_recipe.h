#ifndef BASE_BRIDGE_RECIPE_H
#define BASE_BRIDGE_RECIPE_H

#include "../base_specs/bridge.h"

class BaseBridgeRecipe
{
public:
    void find(Atom *anchor) const;

private:
    void findChildren(Atom *anchor) const;
};

#endif // BASE_BRIDGE_RECIPE_H
