#include <atoms/lattice.h>
#include <hand-generations/phases/diamond.h>
using namespace vd;

#include "../support/open_diamond.h"

int main(int argc, char const *argv[])
{
    Crystal *diamond = new OpenDiamond(2);
    Lattice lattice(diamond, int3(1, 2, 3));
    assert(lattice.crystal() == diamond);
    assert(lattice.coords().x == 1);
    assert(lattice.coords().y == 2);
    assert(lattice.coords().z == 3);

    Crystal *other = new Diamond(dim3(3, 3, 3));
    assert(lattice.crystal() != other);

    lattice.updateCoords(int3(3, 2, 1));
    assert(lattice.coords().x == 3);
    assert(lattice.coords().y == 2);
    assert(lattice.coords().z == 1);

    delete other;
    delete diamond;

    return 0;
}
