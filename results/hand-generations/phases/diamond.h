#ifndef DIAMOND_H
#define DIAMOND_H

#include <phases/crystal.h>
using namespace vd;

#include "diamond_relations.h"

class Diamond : public DiamondRelations<Crystal>
{
    int _defaultSurfaceHeight;

public:
#ifndef NDEBUG
    typedef DiamondRelations<Crystal> Relations;
#endif // NDEBUG

    Diamond(const dim3 &sizes, int defaultSurfaceHeight = 3);
    ~Diamond();

protected:
    const float3 &periods() const final;
    float3 seeks(const int3 &coords) const final;

    void buildAtoms() final;
    Atom *makeAtom(ushort type, const int3 &coords) final;
    void bondAllAtoms() final;

    void findAll() final;

private:
//    void bondWithFront110(Atom *atom);
    void bondWithCross110(Atom *atom);
    void bondWithNeighbours(Atom *atom, DiamondRelations::TN &neighbours);
};

#endif // DIAMOND_H
