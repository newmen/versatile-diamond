#ifndef ATOMIC_RECIPE_H
#define ATOMIC_RECIPE_H

#include "../dictionary.h"
#include "../crystals/diamond.h"

class AtomicRecipe
{
public:
    virtual void find(Atom *anchor) const = 0;
};

#endif // ATOMIC_RECIPE_H
