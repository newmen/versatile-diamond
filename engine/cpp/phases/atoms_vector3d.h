#ifndef ATOMS_VECTOR3D_H
#define ATOMS_VECTOR3D_H

#include "../tools/vector3d.h"

namespace vd
{

template <class AtomType>
class AtomsVector3d : public vector3d<AtomType *>
{
public:
    AtomsVector3d(const dim3 &sizes) :
        vector3d<AtomType *>(sizes, (AtomType *)nullptr) {}
};

}

#endif // ATOMS_VECTOR3D_H
