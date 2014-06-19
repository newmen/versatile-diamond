#include "sierpinski_drop_left.h"

void SierpinskiDropLeft::doIt()
{
    Atom *atoms[2] = { target()->atom(0), target()->atom(1) };
    doItWith(atoms);
}
