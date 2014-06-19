#include "sierpinski_drop_right.h"

void SierpinskiDropRight::doIt()
{
    Atom *atoms[2] = { target()->atom(4), target()->atom(5) };
    doItWith(atoms);
}
