#include <lattice.h>
#include <generations/crystals/diamond.h>

using namespace vd;

int main(int argc, char const *argv[])
{
    Crystal *diamond = new Diamond(dim3(10, 10, 5));
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
