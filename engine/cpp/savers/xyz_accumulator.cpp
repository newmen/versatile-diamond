#include "xyz_accumulator.h"

namespace vd
{

void XYZAccumulator::treatHidden(const vd::SavingAtom *first, const vd::SavingAtom *second)
{
    if (!detector()->isShown(first) && detector()->isShown(second))
    {
        _atoms.insert(second);
    }
}

void XYZAccumulator::pushPair(const SavingAtom *first, const SavingAtom *second)
{
    _atoms.insert(first);
    _atoms.insert(second);
}

}
