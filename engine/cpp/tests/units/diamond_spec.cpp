#include <hand-generations/atoms/c.h>
#include <hand-generations/phases/diamond.h>
using namespace vd;

#include "../support/open_diamond.h"

int main(int argc, char const *argv[])
{
    OpenDiamond *diamond = new OpenDiamond(2);
    diamond->initialize();
    assert(diamond->countAtoms() == OpenDiamond::SIZES.x * OpenDiamond::SIZES.y * 2);

    for (int x = 0; x < OpenDiamond::SIZES.x; ++x)
        for (int y = 0; y < OpenDiamond::SIZES.y; ++y)
            for (int z = 0; z < OpenDiamond::SIZES.z; ++z)
            {
                if (z > 1)
                {
                    assert(!diamond->atom(int3(x, y, z)));
                }
                else
                {
                    uint type = (z == 0) ? 24 : 1;
                    assert(diamond->atom(int3(x, y, z))->is(type));
                }
            }
    delete diamond;

    diamond = new OpenDiamond(3);
    diamond->initialize();
    assert(diamond->countAtoms() == OpenDiamond::SIZES.x * OpenDiamond::SIZES.y * 3);

    C *c = new C(3, 0, (Lattice *)nullptr);
    diamond->insert(c, int3(3, 3, 3));
    assert(diamond->atom(int3(3, 3, 3)) == c);
    assert(c->lattice());
    assert(c->lattice()->coords().x == 3);
    assert(c->lattice()->coords().y == 3);
    assert(c->lattice()->coords().z == 3);

    diamond->erase(c);
    assert(!diamond->atom(int3(3, 3, 3)));
    assert(!c->lattice());

    diamond->insert(c, int3(1, 2, 3));
    assert(diamond->atom(int3(1, 2, 3)) == c);
    assert(c->lattice());

    diamond->erase(c);
    assert(!diamond->atom(int3(1, 2, 3)));
    assert(!c->lattice());

    delete diamond;
    return 0;
}
