#include "behavior_tor.h"
#include "atoms_vector3d.h"

namespace vd
{

int BehaviorTor::correctOne(int value, uint max) const
{
    if (value < 0) return (int)max + value;
    else if (value >= (int)max) return (int)max - value;
    return value;
}

Atom *&BehaviorTor::getData(AtomsVector3d *atomsVector, const int3 &coords) const
{
    return atomsVector->ParentType::operator[](correct(atomsVector, coords));
}

int3 BehaviorTor::correct(AtomsVector3d *atomsVector, const int3 &coords) const
{
    assert(coords.z >= 0);
    assert(coords.z < (int)atomsVector->sizes().z);

    int3 result = coords;
    result.x = correctOne(coords.x, atomsVector->sizes().x);
    result.y = correctOne(coords.y, atomsVector->sizes().y);
    return result;
}

}
