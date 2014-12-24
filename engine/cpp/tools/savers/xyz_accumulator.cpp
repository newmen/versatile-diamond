#include "xyz_accumulator.h"

namespace vd
{

void XYZAccumulator::treatHidden(const vd::Atom *first, const vd::Atom *second)
{
    if (!detector()->isShown(first) && detector()->isShown(second))
    {
        _atoms.insert(second);
    }
}

void XYZAccumulator::pushPair(const Atom *first, const Atom *second)
{
    _atoms.insert(first);
    _atoms.insert(second);
}

}
