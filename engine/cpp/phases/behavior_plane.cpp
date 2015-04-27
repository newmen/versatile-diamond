#include "behavior_plane.h"
#include "smart_atoms_vector3d.h"

namespace vd
{

Atom *&BehaviorPlane::getData(SmartAtomsVector3d<Atom> *atomsVector, const int3 &coords) const
{
    static Atom *nullAtom = nullptr;

    if (isOut(atomsVector, coords))
    {
        return nullAtom;
    }
    else
    {
        return atomsVector->BaseVector::operator[](coords);
    }
}

bool BehaviorPlane::isOut(const SmartAtomsVector3d<Atom> *atomsVector, const int3 &coords) const
{
    const int cx = coords.x, cy = coords.y;
    if (cx < 0 || (uint)cx >= atomsVector->sizes().x || cy < 0 || (uint)cy >= atomsVector->sizes().y)
        return true;
    else return false;
}

}
