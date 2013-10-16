#ifndef UBIQUITOUS_REACTION_RECIPE_H
#define UBIQUITOUS_REACTION_RECIPE_H

#include "../../base_recipe.h"

class UbiquitousReactionRecipe : public BaseRecipe
{
public:
    short delta(Atom *anchor) const
    {
        uint currNum = num(anchor->type());
        uint prevNum;
        if (anchor->prevType() == (uint)(-1))
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
    virtual uint num(uint type) const = 0;
};

#endif // UBIQUITOUS_REACTION_RECIPE_H
