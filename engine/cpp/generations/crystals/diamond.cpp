#include "diamond.h"
#include "../builders/diamond_atom_builder.h"

void Diamond::buildAtoms()
{
    DiamondAtomBuilder atomBuilder;

    makeLayer(&atomBuilder, 0, 1);
    makeLayer(&atomBuilder, 1, 0);
}

void Diamond::bondAllAtoms()
{

}
