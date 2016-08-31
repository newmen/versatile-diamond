#ifndef BEHAVIOR_H
#define BEHAVIOR_H

#include "../tools/common.h"

namespace vd
{

template <class A>
class SmartAtomsVector3d;
class Atom;

class Behavior
{   
public:
    virtual ~Behavior() {}
    virtual Atom *&getData(SmartAtomsVector3d<Atom> *atomsVector, const int3 &coords) const = 0;

protected:
    Behavior() = default;
};

}

#endif // BEHAVIOR_H
