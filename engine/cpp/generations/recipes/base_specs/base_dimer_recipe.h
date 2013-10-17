#ifndef BASE_DIMER_RECIPE_H
#define BASE_DIMER_RECIPE_H

#include "../atomic_recipe.h"

class BaseDimerRecipe : public AtomicRecipe
{
public:
    void find(Atom *anchor) const override;

private:
    void findChildren(Atom *anchor) const;
};

#endif // BASE_DIMER_RECIPE_H
