#include "c.h"
#include "../recipes/base_specs/base_bridge_recipe.h"

void C::findChildren()
{
#pragma omp parallel sections
    {
#pragma omp section
        {
            BaseBridgeRecipe bbr;
            bbr.find(this);
        }
#pragma omp section
        {
            SpecifiedAtom::findChildren();
        }
    }

}
