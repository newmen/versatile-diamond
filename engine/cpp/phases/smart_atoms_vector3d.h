#ifndef SMART_ATOMS_VECTOR3D_H
#define SMART_ATOMS_VECTOR3D_H

#include "atoms_vector3d.h"
#include "behavior.h"

namespace vd
{

template <class A>
class SmartAtomsVector3d : public AtomsVector3d<A>
{
    const Behavior *_behavior = nullptr;

public:
    typedef vector3d<A *> BaseVector;

    SmartAtomsVector3d(const dim3 &sizes, const Behavior *bhvr) :
        AtomsVector3d<A>(sizes), _behavior(bhvr) {}

    ~SmartAtomsVector3d()
    {
        delete _behavior;
    }

    void changeBehavior(const Behavior *behavior)
    {
        delete _behavior;
        _behavior = behavior;
    }

    A *&operator [] (const int3 &coords)
    {
        return _behavior->getData(this, coords);
    }

private:
    SmartAtomsVector3d(const SmartAtomsVector3d &) = delete;
    SmartAtomsVector3d(SmartAtomsVector3d &&) = delete;
    SmartAtomsVector3d &operator = (const SmartAtomsVector3d &) = delete;
    SmartAtomsVector3d &operator = (SmartAtomsVector3d &&) = delete;
};

}

#endif // SMART_ATOMS_VECTOR3D_H

