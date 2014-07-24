#ifndef BEHAVIOR_H
#define BEHAVIOR_H

#include "../tools/common.h"

namespace vd
{

class Atom;
class AtomsVector3d;

class Behavior
{   
public:
    virtual ~Behavior() {}
    virtual Atom *&getData(AtomsVector3d *atomsVector, const int3 &coords) const = 0;

protected:
    Behavior() = default;
};

}

#endif // BEHAVIOR_H
