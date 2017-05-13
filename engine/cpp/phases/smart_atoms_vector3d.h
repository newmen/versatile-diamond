#ifndef SMART_ATOMS_VECTOR3D_H
#define SMART_ATOMS_VECTOR3D_H

#include "atoms_vector3d.h"
#include "behavior.h"

namespace vd
{

template <class AtomType>
class SmartAtomsVector3d : public AtomsVector3d<AtomType>
{
    const Behavior *_behavior = nullptr;

public:
    typedef AtomsVector3d<AtomType> BaseVector;

    SmartAtomsVector3d(const dim3 &sizes, const Behavior *bhvr) :
        BaseVector(sizes), _behavior(bhvr) {}

    ~SmartAtomsVector3d()
    {
        delete _behavior;
    }

    void changeBehavior(const Behavior *behavior)
    {
        delete _behavior;
        _behavior = behavior;
    }

    AtomType *&operator [] (const int3 &coords)
    {
        return _behavior->choiseAtom(this, coords);
    }
};

}

#endif // SMART_ATOMS_VECTOR3D_H

