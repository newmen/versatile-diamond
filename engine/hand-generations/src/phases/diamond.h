#ifndef DIAMOND_H
#define DIAMOND_H

#include <phases/crystal.h>
using namespace vd;

#include "diamond_crystal_properties.h"
#include "../cpp/phases/behavior.h"

class Diamond : public DiamondCrystalProperties<Crystal>
{
    int _defaultSurfaceHeight;

public:
#ifndef NDEBUG
    typedef DiamondRelations<Crystal> Relations;
#endif // NDEBUG

    Diamond(const dim3 &sizes, const Behavior *behavior, int defaultSurfaceHeight = 3);
    ~Diamond();

protected:
    void buildAtoms() final;
    Atom *makeAtom(ushort type, ushort actives, const int3 &coords) final;
    void bondAllAtoms() final;

    void findAll() final;
};

#endif // DIAMOND_H
