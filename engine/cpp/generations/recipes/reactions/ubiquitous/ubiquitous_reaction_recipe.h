#ifndef UBIQUITOUS_REACTION_RECIPE_H
#define UBIQUITOUS_REACTION_RECIPE_H

#include "../../atomic_recipe.h"

class UbiquitousReactionRecipe : public AtomicRecipe
{
public:
    short delta(Atom *anchor) const
    {
        ushort currNum = num(anchor->type());
        ushort prevNum;
        if (anchor->prevType() == (ushort)(-1))
        {
            prevNum = 0;
        }
        else
        {
            prevNum = num(anchor->prevType());
        }
        return currNum - prevNum;
    }

protected:
    virtual ushort num(ushort type) const = 0;
};

#endif // UBIQUITOUS_REACTION_RECIPE_H
