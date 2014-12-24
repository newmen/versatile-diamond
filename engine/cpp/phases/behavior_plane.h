#ifndef BEHAVIOR_PLANE_H
#define BEHAVIOR_PLANE_H

#include "behavior.h"

namespace vd {

class BehaviorPlane : public Behavior
{
public:
    BehaviorPlane() = default;

    Atom *&getData(AtomsVector3d *atomsVector, const int3 &coords) const override;

private:
    bool isOut (const AtomsVector3d *atomsVector, const int3 &coords) const;
};

}
#endif // BEHAVIOR_PLANE_H
