#ifndef TARGET_ATOMS_H
#define TARGET_ATOMS_H

#include "../species/specific_spec.h"

namespace vd
{

class TargetAtoms
{
    SpecificSpec *_target;

    ushort _atomsNum;
    const ushort *_indexes;
    const ushort *_types;

    Atom *anchor(ushort index) const
    {
        return _target->atom(_indexes[index]);
    }

    bool isCorrect(ushort index) const
    {
        return anchor(index)->is(_types[index]);
    }

    bool prevCorrect(ushort index) const
    {
        return anchor(index)->prevIs(_types[index]);
    }

public:
    TargetAtoms(SpecificSpec *target, ushort atomsNum, const ushort *indexes, const ushort *types) :
        _target(target), _atomsNum(atomsNum), _indexes(indexes), _types(types) {}

    SpecificSpec *target() const { return _target; }
    Atom *firstAnchor() const { return anchor(0); }

    bool isUpdated() const
    {
        for (ushort i = 0; i < _atomsNum; ++i)
        {
            assert(isCorrect(i));
            if (prevCorrect(i)) return true;
        }

        return false;
    }
};

}

#endif // TARGET_ATOMS_H
