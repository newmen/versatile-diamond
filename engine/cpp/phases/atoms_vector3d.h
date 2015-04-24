#ifndef ATOMS_VECTOR3D_H
#define ATOMS_VECTOR3D_H

#include "../tools/vector3d.h"

namespace vd
{

template <class A>
class AtomsVector3d : public vector3d<A *>
{
public:
    AtomsVector3d(const dim3 &sizes) :
        vector3d<A *>(sizes, (A *)nullptr) {}

private:
    AtomsVector3d(const AtomsVector3d &) = delete;
    AtomsVector3d(AtomsVector3d &&) = delete;
    AtomsVector3d &operator = (const AtomsVector3d &) = delete;
    AtomsVector3d &operator = (AtomsVector3d &&) = delete;
};

}

#endif // ATOMS_VECTOR3D_H
