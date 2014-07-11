#include "accumulator.h"

namespace vd
{

void Accumulator::addBondedPair(const Atom *from, const Atom *to)
{
    assert(from != to);

    if (!detector()->isShown(from) || !detector()->isShown(to))
    {
        treatHidden(from, to);
    }
    else
    {
        pushPair(from, to);
    }
}

}
