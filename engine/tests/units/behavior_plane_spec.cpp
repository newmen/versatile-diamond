#include <atoms/c.h>
#include <phases/behavior_plane.h>
#include <phases/diamond.h>
using namespace vd;

#include "../support/open_diamond.h"

int main(int argc, char const *argv[])
{
    const ushort height = 7;
    Crystal *diamond = new OpenDiamond(OpenDiamond::SIZES, new BehaviorPlane, height);
    diamond->initialize();
    assert(diamond->countAtoms() == OpenDiamond::SIZES.x * OpenDiamond::SIZES.y * height);

    for (int x = 0; x < OpenDiamond::SIZES.x; ++x)
        for (int y = 0; y < OpenDiamond::SIZES.y; ++y)
        {
            assert(diamond->atom(int3(x, y, 0))->type() == 24);
            assert(diamond->atom(int3(x, y, height - 1))->is(2));
        }

    for (int x = 0; x < OpenDiamond::SIZES.x; ++x)
    {
        for (int z = 1; z < height - 1; z += 2)
        {
            assert(diamond->atom(int3(x, 0, z))->is(5));
            assert(diamond->atom(int3(x, OpenDiamond::SIZES.y - 1, z))->is(5));
        }
        for (int z = 2; z < height - 1; z += 2)
        {
            assert(diamond->atom(int3(x, 0, z))->is(24));
            assert(diamond->atom(int3(x, OpenDiamond::SIZES.y - 1, z))->is(24));
        }
    }

    for (int y = 0; y < OpenDiamond::SIZES.y; ++y)
    {
        for (int z = 1; z < height - 1; z += 2)
        {
            assert(diamond->atom(int3(0, y, z))->is(24));
            assert(diamond->atom(int3(OpenDiamond::SIZES.x - 1, y, z))->is(24));
        }
        for (int z = 2; z < height - 1; z += 2)
        {
            assert(diamond->atom(int3(0, y, z))->is(5));
            assert(diamond->atom(int3(OpenDiamond::SIZES.x - 1, y, z))->is(5));
        }
    }

    delete diamond;
    return 0;
}
