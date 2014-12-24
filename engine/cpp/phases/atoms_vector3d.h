#ifndef ATOMS_VECTOR3D_H
#define ATOMS_VECTOR3D_H

#include "../tools/vector3d.h"
#include "behavior.h"

namespace vd {

class AtomsVector3d : public vector3d<Atom *>
{
    const Behavior *_behavior = nullptr;

public:
    typedef vector3d<Atom *> ParentType;

    AtomsVector3d(const Behavior *bhvr, const dim3 &sizes) :
        vector3d(sizes, (Atom *)nullptr), _behavior(bhvr) {}
    ~AtomsVector3d()
    {
        delete _behavior;
    }

    void changeBehavior(const Behavior *behavior)
    {
        delete _behavior;
        _behavior = behavior;
    }

    Atom *&operator [] (const int3 &coords)
    {
        return _behavior->getData(this, coords);
    }
};

}

#endif // ATOMS_VECTOR3D_H
