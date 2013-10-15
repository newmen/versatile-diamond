#ifndef BASE_DIMER_RECIPE_H
#define BASE_DIMER_RECIPE_H

#include "../base_specs/dimer.h"

class BaseDimerRecipe
{
public:
    void find(Atom *anchor) const;

private:
    void findChildren(Atom *anchor) const;
};

#endif // BASE_DIMER_RECIPE_H
