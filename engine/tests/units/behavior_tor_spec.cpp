#include <phases/behavior_tor.h>
using namespace vd;

#include "../support/open_diamond.h"

int main(int argc, char const *argv[])
{
    const ushort height = 7;
    Crystal *diamond = new OpenDiamond(OpenDiamond::SIZES, new BehaviorTor, height);
    diamond->initialize();
    assert(diamond->countAtoms() == OpenDiamond::SIZES.x * OpenDiamond::SIZES.y * height);

    for (int x = 0; x < OpenDiamond::SIZES.x; ++x)
        for (int y = 0; y < OpenDiamond::SIZES.y; ++y)
        {
            for (int z = 0; z < height - 1; ++z)
            {
                assert(diamond->atom(int3(x, y, z))->type() == 24);
            }
            assert(diamond->atom(int3(x, y, height - 1))->is(2));
        }

    delete diamond;
    return 0;
}
