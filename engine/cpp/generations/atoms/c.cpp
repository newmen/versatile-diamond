#include "c.h"
#include "../base_specs/bridge.h"

void C::findChildren()
{
#pragma omp parallel sections
    {
#pragma omp section
        {
            Bridge::find(this);
        }
#pragma omp section
        {
            SpecifiedAtom::findChildren();
        }
    }

}
