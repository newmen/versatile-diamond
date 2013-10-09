#include "diamond.h"

void Diamond::buildAtoms()
{
    const dim3 &sizes = atoms().sizes();

    return atomBuilder->build(this, coords);
}

void Diamond::bondAllAtoms()
{

}
