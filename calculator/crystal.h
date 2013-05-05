#ifndef CRYSTAL_H
#define CRYSTAL_H

#include "common.h"
#include "vector3d.h"

namespace vd
{

class Atom;
class CompositionBuilder;

class Crystal
{
protected:
    vector3d<Atom *> _atoms;

public:
    Crystal(const dim3 &sizes, const CompositionBuilder *atomBuilder);
    virtual ~Crystal();

    virtual void bondTogether() = 0;

private:
};

}

#endif // CRYSTAL_H
