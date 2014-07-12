#include "xyz_accumulator.h"

namespace vd
{

void XYZAccumulator::treatHidden(const vd::Atom *first, const vd::Atom *second)
{
    if (!detector()->isShown(first) && detector()->isShown(second))
    {
        storeAtom(second);
    }
}

void XYZAccumulator::pushPair(const Atom *first, const Atom *second)
{
    storeAtom(first);
    storeAtom(second);
}

void XYZAccumulator::storeAtom(const Atom *atom)
{
    if (_atoms.find(atom) == _atoms.cend())
    {
        _atoms.insert(Atoms::value_type(atom, VolumeAtom(atom)));
    }
}

}
