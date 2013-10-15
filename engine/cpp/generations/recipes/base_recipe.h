#ifndef BASE_RECIPE_H
#define BASE_RECIPE_H

#include "../dictionary.h"
#include "../crystals/diamond.h"

class BaseRecipe
{
public:
    virtual void find(Atom *anchor) const = 0;

protected:
    virtual void findChildren(Atom *anchor) const = 0;
};


#endif // BASE_RECIPE_H
