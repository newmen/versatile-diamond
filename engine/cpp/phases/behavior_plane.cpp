#include "behavior_plane.h"
#include "atoms_vector3d.h"

namespace vd
{

Atom *&BehaviorPlane::getData(AtomsVector3d *atomsVector, const int3 &coords) const
{
    static Atom *nullAtom = nullptr;

    if (isOut(atomsVector, coords))
    {
        return nullAtom;
    }
    else
    {
        return atomsVector->ParentType::operator[](coords);
    }
}

bool BehaviorPlane::isOut(const AtomsVector3d *atomsVector, const int3 &coords) const
{
    const int cx = coords.x, cy = coords.y;
    if (cx < 0 || (uint)cx >= atomsVector->sizes().x || cy < 0 || (uint)cy >= atomsVector->sizes().y)
        return true;
    else return false;
}

}
