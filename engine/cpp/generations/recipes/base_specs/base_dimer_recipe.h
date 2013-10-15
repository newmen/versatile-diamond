#ifndef BASE_DIMER_RECIPE_H
#define BASE_DIMER_RECIPE_H

#include "../base_recipe.h"

class BaseDimerRecipe : public BaseRecipe
{
public:
    void find(Atom *anchor) const override;

private:
    void findChildren(Atom *anchor) const override;
};

#endif // BASE_DIMER_RECIPE_H
