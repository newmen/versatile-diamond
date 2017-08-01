#include <phases/behavior_plane.h>
using namespace vd;

#include "../support/open_diamond.h"

uint crystalAtomsNum(ushort height)
{
    uint numX = OpenDiamond::SIZES.x;
    uint numY = OpenDiamond::SIZES.y;
    uint totalNum = numX * numY;
    for (ushort i = 1; i < height; ++i)
    {
        if (i % 2 == 0) --numX;
        else --numY;
        totalNum += numX * numY;
    }
    return totalNum;
}

int main(int argc, char const *argv[])
{
    const ushort height = 8;
    Crystal *diamond = new OpenDiamond(OpenDiamond::SIZES, new BehaviorPlane, height);
    diamond->initialize();
    assert(diamond->countAtoms() == crystalAtomsNum(height));

    for (uint x = 0; x < OpenDiamond::SIZES.x; ++x)
        for (uint y = 0; y < OpenDiamond::SIZES.y; ++y)
        {
            assert(diamond->atom(int3(x, y, 0))->type() == 24);

            for (uint z = 1; z < height - 1; ++z)
            {
                uint maxX = OpenDiamond::SIZES.x - (z+1)/2 - 1;
                uint maxY = OpenDiamond::SIZES.y - z/2 - 1;
                const Atom *atom = diamond->atom(int3(x, y, z));
                if (x > maxX || y > maxY)
                {
                    assert(!atom);
                }
                else if ((x == 0 || x == maxX || y == 0 || y == maxY)
                        && !(z % 2 == 0 && x > 0 && x < maxX)
                        && !(z % 2 == 1 && y > 0 && y < maxY))
                {
                    assert(atom->is(5));
                }
                else
                {
                    assert(atom->type() == 24);
                }
            }

            const Atom *topAtom = diamond->atom(int3(x, y, height - 1));
            if (x < OpenDiamond::SIZES.x - 4 && y < OpenDiamond::SIZES.y - 3)
            {
                assert(topAtom->is(2));
            }
            else
            {
                assert(!topAtom);
            }
        }

    delete diamond;
    return 0;
}
